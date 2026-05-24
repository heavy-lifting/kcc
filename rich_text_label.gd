extends RichTextLabel

@onready var network_manager = $"../.." # Path to your GHCI node

func _ready():
	# Connect the network manager's signal to this window
	network_manager.ghci_output_received.connect(_on_ghci_output_received)
	
	# Clear any default text
	text = "--- messages from the computer :] ---\n"

func _on_ghci_output_received(new_line: String):
	# Append the new line from GHCI to the bottom of our window
	append_text(new_line + "\n")
	
	# Optional: Automatically scroll to the bottom so you always see latest output
	var scrollbar = get_v_scroll_bar()
	scrollbar.value = scrollbar.max_value

#func _on_ghci_output_received(new_line: String):
	## Force this specific operation to happen safely on the main game thread
	#call_deferred("_safe_append_text", new_line)
#
#func _safe_append_text(new_line: String):
	#print("append text has been called!")
	#append_text(new_line + "\n")
	#
	## Scroll to bottom safely
	#var scrollbar = get_v_scroll_bar()
	#scrollbar.value = scrollbar.max_value
