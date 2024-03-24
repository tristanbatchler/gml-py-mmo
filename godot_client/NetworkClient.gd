extends Node

const Msgpack = preload("res://Msgpack.gd")
static var EVERYONE: String = "AAAAAAAAAAAAAAAAAAAAAA=="

var socket := WebSocketPeer.new()

@export var hostname: String = "localhost"
@export var port: int = 8081

func _ready() -> void:
	#var cert: X509Certificate = X509Certificate.new()
	#cert.load("res://rootCA.crt")
	var tls_options: TLSOptions = TLSOptions.client()
	var err: int = socket.connect_to_url("wss://%s:%d" % [hostname, port], tls_options)
	if err:
		printerr("Unable to connect")
		set_process(false)
		StateManager._on_network_client_error(err)
	else:
		StateManager._on_network_client_connected()
	

func _process(delta) -> void:
	socket.poll()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet: Dictionary = Msgpack.decode(socket.get_packet())["result"]
			StateManager._on_network_client_received(packet)
			print("Received packet %s" % packet)

func send_packet(packet: Dictionary) -> void:
	var data: PackedByteArray = Msgpack.encode(packet)["result"]
	var err: int = socket.send(data)
	if err:
		printerr("Error sending data. Error code: ", err)
		set_process(false)
		StateManager._on_network_client_error(err)
		
func _exit_tree():
	socket.close()

func _on_button_ping_pressed():
	socket.send_text("Ping")
