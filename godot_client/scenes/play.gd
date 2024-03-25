extends StateScene

const ActorScene = preload("res://actor.tscn")
@onready var chatbox: LineEdit = $CanvasLayer/UI/VBoxContainer/LineEdit

func _ready():
	super._ready()
	chatbox.connect("text_submitted", _on_chatbox_text_submitted)

func _on_chatbox_text_submitted(entered_text: String):
	if entered_text.length() <= 0:
		chatbox.release_focus()
		return
		
	chatbox.clear()
	NetworkClient.send_packet({
		"chat": {
			"from_pid": StateManager.pid,
			"to_pid": NetworkClient.EVERYONE,
			"message": entered_text
		}
	})
	
func _input(event):
	if event.is_action_released("ui_chat_focus"):
		chatbox.grab_focus()
	elif event.is_action_released("ui_chat_release"):
		chatbox.release_focus()

func do_logout():
	NetworkClient.send_packet({
		"disconnect": {
			"from_pid": StateManager.pid,
			"to_pid": NetworkClient.EVERYONE,
			"reason": "User logged out"
		}
	})
	for actor in StateManager.pids_actors.values():
		actor.queue_free()
		
	StateManager.pids_actors.clear()

func _on_packet_received(p_type: String, p_data: Dictionary):	
	var from_pid: String = Marshalls.raw_to_base64(p_data["from_pid"])
	
	if p_type == "Chat":
		if StateManager.pids_actors.has(from_pid):
			var message: String = p_data["message"]
			var actor_chatting: CharacterBody2D = StateManager.pids_actors[from_pid]
			UI.add_to_log("%s says: %s" % [actor_chatting.actor_name, message], UI.GREEN if from_pid == StateManager.pid else UI.BLUE)
			actor_chatting.say(message)
		
	if p_type == "Hello":
		var actor_data: Dictionary = p_data["state_view"]
		var x: int = actor_data["x"]
		var y: int = actor_data["y"]
		var actor_name: String = actor_data["name"]
		var image_index: int = actor_data["image_index"]
		
		if not StateManager.pids_actors.has(from_pid):
			var new_actor: CharacterBody2D = ActorScene.instantiate().init(Vector2(x, y), actor_name, image_index, from_pid == StateManager.pid)
			StateManager.pids_actors[from_pid] = new_actor
			add_child(new_actor)
		
	if p_type == "Move":
		var delta_pos: Vector2 = Vector2(p_data["dx"], p_data["dy"])
		if from_pid != StateManager.pid and StateManager.pids_actors.has(from_pid):
			var actor_moved: CharacterBody2D = StateManager.pids_actors[from_pid]
			actor_moved.enqueue_input(delta_pos.normalized())
			
	if p_type == "Disconnect":
		if StateManager.pids_actors.has(from_pid):
			var actor_disconnected: CharacterBody2D = StateManager.pids_actors[from_pid]
			UI.add_to_log("%s has disconnected due to %s" % [actor_disconnected.actor_name, p_data["reason"]])
			actor_disconnected.queue_free()
			StateManager.pids_actors.erase(from_pid)
