extends StateScene

@onready var username_field: LineEdit = $CanvasLayer/UI/MarginContainer/VBoxContainer/Username/LineEdit
@onready var password_field: LineEdit = $CanvasLayer/UI/MarginContainer/VBoxContainer/Password/LineEdit
@onready var login_button: Button = $CanvasLayer/UI/MarginContainer/VBoxContainer/Buttons/Login
@onready var register_button: Button = $CanvasLayer/UI/MarginContainer/VBoxContainer/Buttons/Register

func _ready():
	super._ready()
	NetworkClient.connect("server_connected", _on_server_connected)
	NetworkClient.connect("server_error", _on_server_error)

func _on_server_connected():
	UI.add_to_log("Server connected successfully!", UI.GREEN)
	
func _on_server_error(err: int):
	UI.add_to_log("Server errored with code %d" % err, UI.YELLOW)
	get_tree().quit()

func do_login(username: String, password: String):
	get_tree().change_scene_to_file("res://scenes/login.tscn")
	NetworkClient.send_packet({
		"login": {
			"from_pid": StateManager.pid,
			"username": username,
			"password": password
		}
	})
	
func do_register(username: String, password: String):
	get_tree().change_scene_to_file("res://scenes/register.tscn")
	NetworkClient.send_packet({
		"register": {
			"from_pid": StateManager.pid,
			"username": username,
			"password": password
		}
	})

func _on_packet_received(p_type: String, p_data: Dictionary):	
	if p_type == "Motd":
		UI.add_to_log(p_data["message"])
		UI.add_to_log("Start by registering with '/register username password'");
		UI.add_to_log("Then you can login with '/login username password'");
		UI.add_to_log("Once you're in the game, you can chat freely or logout with '/logout'");
		UI.add_to_log("You can view this message again any time with '/help'");
		
	if p_type == "Pid":
		StateManager.pid = Marshalls.raw_to_base64(p_data["from_pid"])

func _on_login_pressed():
	do_login(username_field.text, password_field.text)

func _on_register_pressed():
	do_register(username_field.text, password_field.text)
