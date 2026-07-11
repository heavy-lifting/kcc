extends CodeEdit

#extends TextEdit

@onready var network_manager = $"../.." # Point this to the node running the GHCI script above
@onready var text_editor = $"."
@onready var post_window = $"../RichTextLabel"
@onready var palette = "res://palettes/bunnies.tres"

# Preload the floating letter scene (update path to match your project)
const FLOATING_LETTER_SCENE = preload("res://floating_letter.tscn")

# Keep track of the last known text length to find what was typed
var last_text_length: int = 0

func _ready() -> void:
	last_text_length = text.length()
	# Connect the built-in text_changed signal to our function
	text_changed.connect(_on_text_changed)

func _on_text_changed() -> void:
	var current_length = text.length()
	
	# Only trigger the effect if a character was actually added (typing, not deleting)
	if current_length > last_text_length:
		# 1. Grab the caret's relative pixel position inside the CodeEdit
		var caret_pos = get_caret_draw_pos()
		
		# 2. Get the specific character that was just typed
		var typed_char = _get_last_typed_character()
		
		# 3. Spawn the floating visual element
		if typed_char != "" and typed_char != " " and typed_char != "\n":
			_spawn_floating_letter(typed_char, caret_pos)
			
	last_text_length = current_length

func _get_last_typed_character() -> String:
	var caret_idx = get_caret_column()
	var line_idx = get_caret_line()
	var line_text = get_line(line_idx)
	
	# Safety check to make sure we aren't pulling an empty index
	if caret_idx > 0 and caret_idx <= line_text.length():
		return line_text[caret_idx - 1]
	return ""

func _spawn_floating_letter(character: String, local_pos: Vector2) -> void:
	var letter_instance = FLOATING_LETTER_SCENE.instantiate()
	letter_instance.text = character
	
	# Match the theme font/color of your editor dynamically if you want!
	letter_instance.add_theme_color_override("font_color", Color(1, 0.4, 0, 1)) # Juicy Orange/Neon
	
	# Position it relative to the CodeEdit node
	# Add a slight offset so it spawns perfectly on the cursor tip
	letter_instance.position = local_pos + Vector2(-5, -15) 
	
	add_child(letter_instance)

#func _gui_input(event):
	#if event is InputEventKey and event.pressed:
		## Check for Ctrl + Enter (or Cmd + Enter on macOS)
		#if event.keycode == KEY_ENTER and (event.ctrl_pressed or event.meta_pressed):
			#evaluate_current_code()
			## Accept the event so a literal newline isn't inserted by accident
			#accept_event() 
		#elif event.keycode == KEY_PERIOD and (event.ctrl_pressed or event.meta_pressed):
			#network_manager.send_to_tidal("hush")

func _gui_input(event):
	# 1. Ignore key releases and ignore system echo repeats!
	if event is InputEventKey and event.pressed and not event.is_echo():
		# Check for Ctrl + Enter (or Cmd + Enter on macOS)
		if event.keycode == KEY_ENTER and (event.ctrl_pressed or event.meta_pressed):
			accept_event() # 2. Move this to the top of the block so Godot drops it immediately
			evaluate_current_code()
		elif event.keycode == KEY_PERIOD and (event.ctrl_pressed or event.meta_pressed):
			accept_event() # Accept this one too!
			network_manager.send_to_tidal("hush")
			

func evaluate_current_code():
	var code_to_send = ""
	
	# Scenario A: If text is selected, evaluate the selection
	if has_selection():
		code_to_send = get_selected_text()
	# Scenario B: Otherwise, evaluate the line the cursor is currently on
	else:
		var current_line_idx = get_caret_line()
		code_to_send = get_line(current_line_idx)
	
	if code_to_send.left(3) == "ccc":
		var string_array = code_to_send.split(" ")
		#for string in string_array:
			#print(string)
		if string_array[1] == "text":
			print("changing text colour to ", string_array[2], " hehe")
			text_editor.add_theme_color_override("font_color", Color(string_array[2]))
		
		if string_array[1] == "bkg":
			print("changing background colour to ", string_array[2], " hheeheeee")
#
			## 1. Grab the existing stylebox from the CodeEdit
			##var current_stylebox = text_editor.get_theme_stylebox("normal") as StyleBoxFlat
#
			## 2. Directly change its background color property
			##text_editor.get_theme_stylebox.bg_color = Color(string_array[2])
			#var temp_stylebox = StyleBoxFlat.new()
			#temp_stylebox.bg_color = Color(string_array[2])
			#text_editor.add_theme_stylebox_override("normal", temp_stylebox) 
			# 1. Fetch the existing stylebox currently applied to your "normal" state
			#    We cast it 'as StyleBoxFlat' so Godot knows it has a .bg_color property
			var current_stylebox = text_editor.get_theme_stylebox("normal") as StyleBoxFlat

			if current_stylebox:
				# 2. Duplicate it! This creates a unique copy just for this node 
				#    so you don't accidentally change every background in the whole app
				var unique_stylebox = current_stylebox.duplicate()
				
				# 3. Directly access and swap the background color using your array
				unique_stylebox.bg_color = Color(string_array[2])
				
				# 4. Push it back onto the node
				text_editor.add_theme_stylebox_override("normal", unique_stylebox)
	
	elif code_to_send.left(3) == "say":
		var text_to_say = code_to_send.right(len(code_to_send)-3)
		print(text_to_say)
		network_manager.	ghci_output_received.emit(text_to_say)

		
	
	else:
		# Format multi-line blocks for GHCI if necessary
		code_to_send = format_for_ghci(code_to_send)
					
		network_manager.send_to_tidal(code_to_send)

## GHCI requires special wrapping `:{` and `:}` for multi-line blocks
func format_for_ghci(text: String) -> String:
	text = text.strip_edges()
	if text.contains("\n"):
		return ":{\n" + text + "\n:}"
	return text
