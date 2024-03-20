register_singleton();

everyone = "AAAAAAAAAAAAAAAAAAAAAA=="

pid = ""
known_others = {};

state = state_entry;

socket = network_create_socket(network_socket_ws);
network_connect_raw_async(socket, "wss://localhost", 443);

write_buffer = buffer_create(16384, buffer_fixed, 1);

send_packet = function(_struct) {
	
	// Inject our PID as the `from_pid` (foreach will only run once since a packet will only have one item)
	struct_foreach(_struct, function(_packet_name, _packet_data) { 
		_packet_data.from_pid = pid;
	});
	
	buffer_seek(write_buffer, buffer_seek_start, 0);
	SnapBufferWriteMessagePack(write_buffer, _struct);
	var _message_length = buffer_tell(write_buffer);
	network_send_raw(socket, write_buffer, _message_length);
};