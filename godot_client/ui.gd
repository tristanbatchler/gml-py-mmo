class_name UserInterface
extends Control

@onready var textbox: RichTextLabel = $TextureRect/MarginContainer/VBoxContainer/RichTextLabel

const BLUE := "00FFFF"
const YELLOW := "FFFF00"
const WHITE := "FFFFFF"
const GREEN := "00FF00"
const BLACK := "000000"

func _ready():
	for message in StateManager.global_log:
		textbox.append_text(message)

func add_to_log(message: String, color: String = BLACK):
	message = "[color=#%s]%s[/color]\n" % [color, message]
	message = message.replace(" ", "    ")  # This font is cool, but its spaces are way too tiny!
	StateManager.global_log.append(message)
	textbox.append_text(message)
