extends Node

const Msgpack = preload("res://Msgpack.gd")
static var EVERYONE: String = "AAAAAAAAAAAAAAAAAAAAAA=="

var socket := WebSocketPeer.new()

signal server_connected()
signal server_error(err: int)
signal packet_received(p_type: String, p_data: Dictionary)
signal packet_error(err: int)

@export var hostname: String = "localhost"
@export var port: int = 9091

func _ready() -> void:
	#var cert: X509Certificate = X509Certificate.new()
	#cert.load("res://rootCA.crt")
	var tls_options: TLSOptions = TLSOptions.client()
	var err: int = socket.connect_to_url("wss://%s:%d" % [hostname, port], tls_options)
	if err:
		printerr("Unable to connect")
		set_process(false)
		server_error.emit(err)
	else:
		server_connected.emit()
	

func _process(delta) -> void:
	socket.poll()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet: Dictionary = Msgpack.decode(socket.get_packet())["result"]
			var p_type: String = packet.keys()[0]
			var p_data: Dictionary = packet[p_type]
			packet_received.emit(p_type, p_data)
			print("Received packet %s" % packet)

func send_packet(packet: Dictionary) -> void:
	var data: PackedByteArray = Msgpack.encode(packet)["result"]
	var err: int = socket.send(data)
	if err:
		printerr("Error sending data. Error code: ", err)
		set_process(false)
		packet_error.emit(err)
		
func _exit_tree():
	socket.close()

func _on_button_ping_pressed():
	socket.send_text("Ping")
