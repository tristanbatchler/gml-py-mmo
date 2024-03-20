function state_entry(_packet_name, _packet_data) {
	switch (_packet_name) {
		case "Pid":
			obj_network_client.pid = pid_to_string(_packet_data.from_pid);
			break;
			
		case "Motd":
			obj_chatbox.add_to_log(_packet_data.message);
			obj_chatbox.add_to_log("Type '/help' to get started");
			break;
		}
}

function state_login(_packet_name, _packet_data) {
	switch (_packet_name) {
		case "Ok":
			obj_chatbox.add_to_log("Logged in successfully", c_lime);
			obj_statemachine.state = state_play;
			break;
		case "Deny":
			var _reason = _packet_data.reason;
			obj_chatbox.add_to_log("Cannot login: " + _reason, c_yellow);
			obj_statemachine.state = state_entry;
			break;
	}
}

function state_register(_packet_name, _packet_data) {
		switch (_packet_name) {
		case "Ok":
			obj_chatbox.add_to_log("Registered successfully", c_lime);	
			obj_statemachine.state = state_entry;
			break;
		case "Deny":
			var _reason = _packet_data.reason;
			obj_chatbox.add_to_log("Cannot register: " + _reason, c_yellow);
			obj_statemachine.state = state_entry;
			break;
	}
}

function state_play(_packet_name, _packet_data) {
	var _from_pid = pid_to_string(_packet_data.from_pid);
	switch (_packet_name) {
		case "Chat":
			var _message = _packet_data.message;
			if (_from_pid == obj_network_client.pid) {
				obj_chatbox.add_to_log(obj_player.name + ": " + _message, c_lime);
			} else {
				var _sender = struct_get(obj_network_client.known_others, _from_pid)
				obj_chatbox.add_to_log(_sender.name + ": " + _message, c_aqua);
			}
			break;
				
		case "Hello":
			
			var _state_view = _packet_data.state_view;
			
			if (_from_pid == obj_network_client.pid) {
				instance_create_layer(0, 0, "Instances", obj_player, _state_view);
				
				obj_chatbox.add_to_log("Welcome back, " + obj_player.name);
			} else {
				if (!struct_exists(obj_network_client.known_others, _from_pid)) {
					var _other = instance_create_layer(0, 0, "Instances", obj_actor, _state_view);
					struct_set(obj_network_client.known_others, _from_pid, _other);
					obj_chatbox.add_to_log(_other.name + " has joined");
				}
			}
			break;
			
		case "Move":
			var _dx = _packet_data.dx;
			var _dy = _packet_data.dy;
			
			if (_from_pid == obj_network_client.pid) {
				obj_player.x += _dx;
				obj_player.y += _dy;
			} else if (struct_exists(obj_network_client.known_others, _from_pid)) {
				var _other = struct_get(obj_network_client.known_others, _from_pid);
				_other.x += _dx;
				_other.y += _dy;
			}
			break;
			
		case "Disconnect":
			var _reason = _packet_data.reason;
			if (struct_exists(obj_network_client.known_others, _from_pid)) {
				var _other = struct_get(obj_network_client.known_others, _from_pid);
				obj_chatbox.add_to_log(_other.name + " has disconnected due to " + string(_reason), c_yellow);
				instance_destroy(_other);
				struct_remove(obj_network_client.known_others, _from_pid);
			}
			break;
	}
}