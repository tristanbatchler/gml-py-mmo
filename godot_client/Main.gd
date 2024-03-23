extends Node

@onready var _network_client: NetworkClient = $NetworkClient
@onready var _textbox: RichTextLabel = $UI/MarginContainer/VBoxContainer/RichTextLabel
@onready var _inputbox: LineEdit = $UI/MarginContainer/VBoxContainer/LineEdit

var _state: Callable = state_entry
var _pid: PackedByteArray = []

func state_entry(p_type: String, p_data: Dictionary):
	if p_type == "Motd":
		_textbox.append_text(p_data["message"] + "\n")
		
	if p_type == "Pid":
		_pid = p_data["from_pid"]
		_textbox.append_text(_pid.hex_encode() + "\n")
		
func state_login(p_type: String, p_data: Dictionary):	
	if p_type == "Ok":
		_textbox.append_text("Login succeeded!\n")
		_state = state_play
	elif p_type == "Deny":
		_textbox.append_text("Login failed... %s\n" % p_data["reason"])
		_state = state_entry
		
func state_register(p_type: String, p_data: Dictionary):
	if p_type == "Ok":
		_textbox.append_text("Registration succeeded! Now login with your new credentials.\n")
	elif p_type == "Deny":
		_textbox.append_text("Registration failed... %s\n" % p_data["reason"])
	
	_state = state_entry
	
func state_play(p_type: String, p_data: Dictionary):
	if p_type == "Chat":
		var from_pid: PackedByteArray = p_data["from_pid"]
		var sender: String = from_pid.hex_encode()
		_textbox.append_text("%s says: %s\n" % [sender, p_data["message"]])
		
func do_login(username: String, password: String):
	_state = state_login
	_network_client.send_packet({
		"login": {
			"from_pid": _pid,
			"username": username,
			"password": password
		}
	})
	
func do_register(username: String, password: String):
	_state = state_register
	_network_client.send_packet({
		"register": {
			"from_pid": _pid,
			"username": username,
			"password": password
		}
	})
		
func process_command(command: String, args: Array[String]):
	if command == "login":
		do_login(args[0], args[1])
	elif command == "register":
		do_register(args[0], args[1])
	else:
		_textbox.append_text("Command '%s' not found" % command)

func _on_network_client_connected():
	_textbox.append_text("Connection with the server established\n")

func _on_network_client_disconnected(code, reason):
	_textbox.append_text("Client disconnected from server with code %s and reason %s\n" % [code, reason])
	get_tree().quit()

func _on_network_client_error(code):
	_textbox.append_text("Network error with code %s\n" % code)
	get_tree().quit()

func _on_network_client_received(packet: Dictionary):
	var p_type: String = packet.keys()[0]
	var p_data: Dictionary = packet[p_type]
	_state.call(p_type, p_data)

func _on_line_edit_text_submitted(new_text: String):
	_inputbox.clear()
	if new_text.begins_with("/"):
		var parts: PackedStringArray = new_text.split(" ")
		var command = parts[0].lstrip("/")
		process_command(command, parts.slice(1, parts.size()))
	elif _state == state_play:
		_network_client.send_packet({
			"chat":
				{
					"from_pid": _pid,
					"message": new_text
				}
		})
	
