extends Control

#@onready var code_edit: CodeEdit = $CodeEdit
#@onready var label: Label = $Label

@onready var text_editor = $PanelContainer/MarginContainer/CodeEdit # $HSplitContainer/CodeEdit
@onready var text_overlay = $PanelContainer/MarginContainer/TextOverlay
@onready var osc_server = $OSCServer # Reference to your GodOSC node
@onready var _animated_sprite = $Bunny/AnimatedSprite2D
#extends Node

var ghci_process: Dictionary
var stdin: FileAccess
var stdout: FileAccess
var stderr: FileAccess

@export var boot_script_path: String = "res://BootTidal.hs" # Path to your BootTidal.hs

# --- NEW STUFF FOR POST WINDOW ---
var output_listen_thread: Thread
var error_listen_thread: Thread
var is_listening: bool = false

# We will use a custom signal to shout to the UI when new text arrives
signal ghci_output_received(text: String)

func _ready():
	start_ghci()
	# Connect the GodOSC signal to our custom function programmatically
	osc_server.message_received.connect(_on_osc_message_received)
	print("OSC Receiver listening on port ", osc_server.port)
	
# This function runs automatically every single time Tidal sends an OSC message
func _on_osc_message_received(address: String, values): # , _time):
	# 1. Let's filter for our specific message path
	#if address == "/ctrl" or address == "/beat":
		# Tidal usually sends data as a list of key-value pairs or raw floats.
		# For troubleshooting, let's print exactly what Tidal is sending us:
	print("Received OSC from Tidal! Address: ", address, " Data: ", values)
	if address == "/text":
		print("changing text colour to ", values[1], " hehe")
		text_overlay.add_theme_color_override("default_color", Color(values[1]))	
	# 2. Apply the cursor color theme override
		text_editor.add_theme_color_override("caret_color", Color(values[1]))
		# 2. Trigger your theme changes!
		#_flash_background_on_beat()
	if address == "/bgr":
		print("changing bgr to ", values[0])
		var current_stylebox = text_editor.get_theme_stylebox("normal") as StyleBoxFlat
		if current_stylebox:
			var new_stylebox = current_stylebox.duplicate()
			# 2. Extract the existing background color
			var base_color : Color = current_stylebox.bg_color
			# 4. Modify just the Red and channel
			base_color.r = values[0]          # Direct override
			# 5. Assign the modified color back to the stylebox
			current_stylebox.bg_color = base_color
	if address == "/bgg":
		print("changing bgg to ", values[0])
		var current_stylebox = text_editor.get_theme_stylebox("normal") as StyleBoxFlat
		if current_stylebox:
			var new_stylebox = current_stylebox.duplicate()
			# 2. Extract the existing background color
			var base_color : Color = current_stylebox.bg_color
			# 4. Modify just the Red and channel
			base_color.g = values[0]          # Direct override
			# 5. Assign the modified color back to the stylebox
			current_stylebox.bg_color = base_color
	
	if address == "/bgb":
		print("changing bgb to ", values[0])
		var current_stylebox = text_editor.get_theme_stylebox("normal") as StyleBoxFlat
		if current_stylebox:
			var new_stylebox = current_stylebox.duplicate()
			# 2. Extract the existing background color
			var base_color : Color = current_stylebox.bg_color
			# 4. Modify just the Red and channel
			base_color.b = values[0]          # Direct override
			# 5. Assign the modified color back to the stylebox
			current_stylebox.bg_color = base_color
	
	if address == "/bga":
		print("changing bga to ", values[0])
		var current_stylebox = text_editor.get_theme_stylebox("normal") as StyleBoxFlat
		if current_stylebox:
			var new_stylebox = current_stylebox.duplicate()
			# 2. Extract the existing background color
			var base_color : Color = current_stylebox.bg_color
			# 4. Modify just the Red and channel
			base_color.a = values[0]          # Direct override
			# 5. Assign the modified color back to the stylebox
			current_stylebox.bg_color = base_color
		
	if address == "/bgc":
		print("changing background to ", values[1])
		var current_stylebox = text_editor.get_theme_stylebox("normal") as StyleBoxFlat

		if current_stylebox:
			# 2. Duplicate it! This creates a unique copy just for this node 
			#    so you don't accidentally change every background in the whole app
			var new_stylebox = current_stylebox.duplicate()
			# 3. Directly access and swap the background color using your array
			new_stylebox.bg_color = Color(values[1])
			# 4. Push it back onto the node
			text_overlay.add_theme_stylebox_override("normal", new_stylebox)
			
	if address == "/bun":
		print("animating sprite.... changing frame to ", values[2])
		_animated_sprite.frame = values[2] # not sure why this is coming through as 3rd thing in list...
		
		

func _exit_tree():
	stop_ghci()

## Starts GHCI and boots TidalCycles
func start_ghci():
	# Convert global path for the OS
	var global_boot_path = ProjectSettings.globalize_path(boot_script_path)
	
	var boot_script_path = "user://BootTidal.hs" # Switch from res:// to user://
	
	# If the file doesn't exist in the user folder yet, let's create a default one!
	if not FileAccess.file_exists(boot_script_path):
		create_default_boot_script(boot_script_path)
		
	# Now globalize will point to a real, physical folder in the OS AppData/Home directory
	#var global_boot_path = ProjectSettings.globalize_path(boot_script_path)
	print("Loading BootTidal from physical path: ", global_boot_path)
	
	# Command arguments to launch ghci with your boot script
	# This mimics how Tidal plugins launch the environment
	var args = ["-ghci-script", global_boot_path]
	
	# Execute the process with pipes for input/output
	ghci_process = OS.execute_with_pipe("ghci", args)
	
	if ghci_process.is_empty():
		print("Failed to start GHCI. Make sure it's in your system PATH.")
		return
		
	stdin = ghci_process["stdio"]
	stdout = ghci_process["stdio"] # In Godot 4, stdio handles both streams
	stderr = ghci_process["stderr"]
	
	#print("GHCI started successfully!")
	
	# --- START THE BACKGROUND THREAD ---
	is_listening = true
	output_listen_thread = Thread.new()
	# Tell the thread to execute our custom loop function
	output_listen_thread.start(_thread_output_listen_loop)
	error_listen_thread = Thread.new()
	error_listen_thread.start(_thread_error_listen_loop)
	print("GHCI and Listen Threads started!")
	
	#print("testing string...")
	#send_to_tidal("d1 $ sound \" bd sn\"")

func create_default_boot_script(target_path: String):
	# Path to your bundled file inside the editor/executable
	var bundled_path = "res://BootTidal.hs"
	
	if FileAccess.file_exists(bundled_path):
		# Open the bundled file from inside the game package for reading
		var source_file = FileAccess.open(bundled_path, FileAccess.READ)
		var content = source_file.get_as_text()
		source_file.close()
		
		# Write that content out to the real hard drive (user://)
		var dest_file = FileAccess.open(target_path, FileAccess.WRITE)
		dest_file.store_string(content)
		dest_file.close()
		
		print("Successfully cloned bundled BootTidal.hs to user://")
	else:
		print("Error: Could not find a bundled BootTidal.hs in res://")

# This function runs entirely in the background
func _thread_output_listen_loop():
	while is_listening:
		#print("listening for outputs")
		if stdout and stdout.is_open():
			# This line waits until GHCI outputs text. 
			# Because it's on a thread, it won't freeze your game UI!
			var output = stdout.get_line()
			#print("output: ", output)
			
			if not output.is_empty():
				# We can't safely modify UI directly from a thread, 
				# so we emit a signal back to the main game.
				#print("output signal being emitted by listener")
				#ghci_output_received.emit(output)
				ghci_output_received.emit.call_deferred(output)
		else:
			# Prevent the loop from running at infinite speed if the pipe closes
			OS.delay_msec(10)

func _thread_error_listen_loop():
	while is_listening:
		#print("listening for errors")
		if stderr and stderr.is_open():
			# This line waits until GHCI outputs text. 
			# Because it's on a thread, it won't freeze your game UI!
			var output_err = stderr.get_line()
			#print("error: ", output_err)
			
			if not output_err.is_empty():
				# We can't safely modify UI directly from a thread, 
				# so we emit a signal back to the main game.
				#print("error signal being emitted by listener")
				#ghci_output_received.emit(output)
				ghci_output_received.emit.call_deferred(output_err)
	
		else:
			# Prevent the loop from running at infinite speed if the pipe closes
			OS.delay_msec(10)

## Sends a raw string of code directly to GHCI
func send_to_tidal(code_line: String):
	if stdin and stdin.is_open():
		# GHCI executes code when it receives a newline
		stdin.store_line(code_line)
		print("Sent: ", code_line)
	else:
		print("Error: GHCI process is not open.")

## Properly close the process when closing the game/editor
func stop_ghci():
	# Clean up the thread safely before closing
	is_listening = false
	if output_listen_thread and output_listen_thread.is_started():
		output_listen_thread.wait_to_finish()
	if error_listen_thread and error_listen_thread.is_started():
		error_listen_thread.wait_to_finish()
	if stdin:
		# Tell GHCI to quit gracefully
		stdin.store_line(":quit")
		stdin.close()
	
	if ghci_process.has("pid"):
		OS.kill(ghci_process["pid"])
		print("GHCI process stopped.")
