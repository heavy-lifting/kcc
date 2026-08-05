extends MarginContainer

@onready var code_edit: CodeEdit = $CodeEdit
@onready var text_overlay: RichTextLabel = $TextOverlay


func _ready() -> void:
	# Connect to CodeEdit's scroll signal
	code_edit.get_v_scroll_bar().value_changed.connect(_on_code_edit_scrolled)

func _on_code_edit_scrolled(line_value: float) -> void:
	var line_height: int = code_edit.get_line_height()
	text_overlay.get_v_scroll_bar().value = line_value * line_height
