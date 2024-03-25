extends Node

var _state: Callable = state_entry
var _pid: String
var _pids_actors: Dictionary = {}

const ActorScene: PackedScene = preload("res://actor.tscn")

func state_entry(p_type: String, p_data: Dictionary):
	if p_type == "Motd":
		UI.textbox.append_text(p_data["message"] + "\n")
		
	if p_type == "Pid":
		_pid = Marshalls.raw_to_base64(p_data["from_pid"])
		UI.textbox.append_text(_pid + "\n")
		
func state_login(p_type: String, p_data: Dictionary):	
	if p_type == "Ok":
		UI.textbox.append_text("Login succeeded!\n")
		_state = state_play
	elif p_type == "Deny":
		UI.textbox.append_text("Login failed... %s\n" % p_data["reason"])
		_state = state_entry
		
func state_register(p_type: String, p_data: Dictionary):
	if p_type == "Ok":
		UI.textbox.append_text("Registration succeeded! Now login with your new credentials.\n")
	elif p_type == "Deny":
		UI.textbox.append_text("Registration failed... %s\n" % p_data["reason"])
	
	_state = state_entry
	
func state_play(p_type: String, p_data: Dictionary):
	var from_pid: String = Marshalls.raw_to_base64(p_data["from_pid"])
	
	if p_type == "Chat":
		if _pids_actors.has(from_pid):
			var actor_chatting: CharacterBody2D = _pids_actors[from_pid]
			UI.textbox.append_text("%s says: %s\n" % [actor_chatting.actor_name, p_data["message"]])
		
	if p_type == "Hello":
		var actor_data: Dictionary = p_data["state_view"]
		var x: int = actor_data["x"]
		var y: int = actor_data["y"]
		var name: String = actor_data["name"]
		var image_index: int = actor_data["image_index"]
		
		var new_actor: CharacterBody2D = ActorScene.instantiate().init(_pid, Vector2(x, y), name, image_index, from_pid == _pid)
		_pids_actors[from_pid] = new_actor
		add_sibling(new_actor)
		
	if p_type == "Move":
		var delta_pos: Vector2 = Vector2(p_data["dx"], p_data["dy"])
		if from_pid != _pid and _pids_actors.has(from_pid):
			var actor_moved: CharacterBody2D = _pids_actors[from_pid]
			actor_moved.enqueue_input(delta_pos.normalized())
			
	if p_type == "Disconnect":
		if _pids_actors.has(from_pid):
			var actor_disconnected: CharacterBody2D = _pids_actors[from_pid]
			UI.textbox.append_text("%s has disconnected due to %s" % [actor_disconnected.actor_name, p_data["reason"]])
			actor_disconnected.queue_free()
		
func do_login(username: String, password: String):
	if _state != state_entry:
		UI.textbox.append_text("You can't login here\n")
		return
	_state = state_login
	NetworkClient.send_packet({
		"login": {
			"from_pid": _pid,
			"username": username,
			"password": password
		}
	})
	
func do_register(username: String, password: String):
	if _state != state_entry:
		UI.textbox.append_text("You can't register here\n")
		return
	_state = state_register
	NetworkClient.send_packet({
		"register": {
			"from_pid": _pid,
			"username": username,
			"password": password
		}
	})
	
func do_logout():
	if _state != state_play:
		UI.textbox.append_text("You can't logout here\n")
	_state = state_entry
	NetworkClient.send_packet({
		"disconnect": {
			"from_pid": _pid,
			"reason": "User logged out"
		}
	})
	for actor in _pids_actors.values():
		actor.queue_free()
		
func process_command(command: String, args: Array[String]):
	if command == "login":
		do_login(args[0], args[1])
	elif command == "register":
		do_register(args[0], args[1])
	elif command == "logout":
		do_logout()
	else:
		UI.textbox.append_text("Command '%s' not found\n" % command)

func _on_network_client_connected():
	UI.textbox.append_text("Connection with the server established\n")

func _on_network_client_disconnected(code, reason):
	UI.textbox.append_text("Client disconnected from server with code %s and reason %s\n" % [code, reason])
	get_tree().quit()

func _on_network_client_error(code):
	UI.textbox.append_text("Network error with code %s\n" % code)
	get_tree().quit()

func _on_network_client_received(packet: Dictionary):
	var p_type: String = packet.keys()[0]
	var p_data: Dictionary = packet[p_type]
	_state.call(p_type, p_data)

func _on_ui_text_submitted(new_text: String):
	if new_text.begins_with("/"):
		var parts: PackedStringArray = new_text.split(" ")
		var command = parts[0].lstrip("/")
		process_command(command, parts.slice(1, parts.size()))
	elif _state == state_play:
		NetworkClient.send_packet({
			"chat":
				{
					"from_pid": _pid,
					"to_pid": NetworkClient.EVERYONE,
					"message": new_text
				}
		})
