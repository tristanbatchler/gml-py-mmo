class_name NetworkClient
extends Node

const Msgpack = preload("res://Msgpack.gd")

signal connected
signal received(packet: Dictionary)
signal disconnected(code: int, reason: String)
signal error(code: int)

var socket := WebSocketPeer.new()

@export var hostname: String = "localhost"
@export var port: int = 8081

func _ready() -> void:
	#var cert: X509Certificate = X509Certificate.new()
	#cert.load("res://rootCA.crt")
	var tls_options: TLSOptions = TLSOptions.client()
	if socket.connect_to_url("wss://%s:%d" % [hostname, port], tls_options) != OK:
		push_error("Unable to connect")
		set_process(false)
	

func _process(delta) -> void:
	socket.poll()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			received.emit(Msgpack.decode(socket.get_packet())["result"])

func send_packet(packet: Dictionary) -> void:
	var data: PackedByteArray = Msgpack.encode(packet)["result"]
	var err: int = socket.send(data)
	if err:
		printerr("Error sending data. Error code: ", err)
		set_process(false)
		error.emit(err)
		
func _exit_tree():
	socket.close()

func _on_button_ping_pressed():
	socket.send_text("Ping")
