extends Control

@onready var textbox: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel
@onready var inputbox: LineEdit = $MarginContainer/VBoxContainer/LineEdit

func _on_line_edit_text_submitted(new_text):
	StateManager._on_ui_text_submitted(new_text)
	inputbox.clear()
