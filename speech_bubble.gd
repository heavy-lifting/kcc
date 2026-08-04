extends Sprite2D

@onready var network_manager = $".." # Path to your GHCI node

# Get a reference to the child text label
@onready var text_label: RichTextLabel = $"../RichTextLabel"

var bubble_tween: Tween

func _ready():
	# Connect the network manager's signal to this window
	network_manager.ghci_output_received.connect(_on_ghci_output_received)
	
	# Clear any default text
	text_label.text = "--- messages from the computer :] ---\n"

func _on_ghci_output_received(new_line: String):
	# Append the new line from GHCI to the bottom of our window
	text_label.append_text(new_line + "\n")
	call_deferred("_scroll_to_bottom")
	
	_pop_up_bubble()

func _scroll_to_bottom():
	var scrollbar = text_label.get_v_scroll_bar()
	scrollbar.value = scrollbar.max_value

func _pop_up_bubble():
	if bubble_tween and bubble_tween.is_running():
		bubble_tween.kill()
	
	show()
	modulate.a = 1.0 
	
	bubble_tween = create_tween()
	
	# Correct Godot 4 method to add a delay/pause in the animation sequence
	bubble_tween.tween_interval(4.0)
	
	# After the 4 second pause, fade out
	bubble_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	bubble_tween.tween_callback(hide)

#func _pop_up_bubble():
	#if bubble_tween and bubble_tween.is_running():
		#bubble_tween.kill()
	#
	#show()
	#modulate.a = 1.0 # This fades BOTH the sprite and the text together!
	#
	#bubble_tween = create_tween()
	#bubble_tween.interval(4.0)
	#bubble_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	#bubble_tween.tween_callback(hide)
