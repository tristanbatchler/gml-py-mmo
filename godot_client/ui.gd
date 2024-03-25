extends CanvasLayer

@onready var textbox: RichTextLabel = $Control/MarginContainer/VBoxContainer/RichTextLabel
@onready var inputbox: LineEdit = $Control/MarginContainer/VBoxContainer/LineEdit

const BLUE := "00FFFF"
const YELLOW := "FFFF00"
const WHITE := "FFFFFF"
const GREEN := "00FF00"

func add_to_log(message: String, color: String = WHITE):
	message = message.replace(" ", "    ")  # This font is cool, but its spaces are way too tiny!
	textbox.append_text("[color=#%s]%s[/color]\n" % [color, message])

func _on_line_edit_text_submitted(new_text):
	StateManager._on_ui_text_submitted(new_text)
	inputbox.clear()
