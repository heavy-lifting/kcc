extends Node2D

@onready var line_edit: LineEdit = $LineEdit
@onready var label: Label = $Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line_edit.text_submitted.connect(_on_LineEdit_text_entered)
	# pass # Replace with function body.

func _on_LineEdit_text_entered(new_text: String) -> void:
	label.text = "Hellooooooo: " + new_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
