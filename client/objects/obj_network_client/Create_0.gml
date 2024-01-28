register_singleton();

socket = network_create_socket(network_socket_ws);
network_connect_raw_async(socket, "localhost", 8081);

write_buffer = buffer_create(16384, buffer_fixed, 1);

send_chat = function(_sender, _message) {
	buffer_seek(write_buffer, buffer_seek_start, 0);
	SnapBufferWriteMessagePack(write_buffer, {
		Chat: {
			sender: _sender, 
			message: _message
		}
	});
	var _message_length = buffer_tell(write_buffer);
	network_send_raw(socket, write_buffer, _message_length);
}

send_login = function(_username, _password) {
	buffer_seek(write_buffer, buffer_seek_start, 0);
	SnapBufferWriteMessagePack(write_buffer, {
		Login: {
			username: _username,
			password: _password
		}
	});
	var _message_length = buffer_tell(write_buffer);
	network_send_raw(socket, write_buffer, _message_length);
}

send_logout = function(_username) {
	buffer_seek(write_buffer, buffer_seek_start, 0);
	SnapBufferWriteMessagePack(write_buffer, {
		Logout: {
			username: _username
		}
	});
	var _message_length = buffer_tell(write_buffer);
	network_send_raw(socket, write_buffer, _message_length);
}

send_register = function(_username, _password) {
	buffer_seek(write_buffer, buffer_seek_start, 0);
	SnapBufferWriteMessagePack(write_buffer, {
		Register: {
			username: _username,
			password: _password
		}
	});
	var _message_length = buffer_tell(write_buffer);
	network_send_raw(socket, write_buffer, _message_length);
}