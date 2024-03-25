class_name StateScene
extends Node

@onready var UI: UserInterface = $CanvasLayer/UI

func _ready():
	NetworkClient.connect("packet_received", _on_packet_received)
	
func _on_packet_received(p_type: String, p_data: Dictionary):
	pass
