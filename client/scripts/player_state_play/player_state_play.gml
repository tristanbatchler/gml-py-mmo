function player_state_play(_packet_name, _packet_data) {
	switch (_packet_name) {
		case "Logout":
			var _username = _packet_data.username;
			if (_username == username) {
				state = player_state_entry;
			}
			break;
			
		case "Hello":
			var _username = _packet_data.username;
			var _x = _packet_data.x;
			var _y = _packet_data.y;
			
			if (_username == username) {
				x = _x;
				y = _y;
			} else {
				var _inst = instance_create_layer(_x, _y, "Instances", obj_other);
				_inst.username = _username;
			}
			break;
			
		case "Move":
			var _username = _packet_data.username;
			var _x = 0;
			var _y = 0;
			if (struct_exists(_packet_data, "x")) {
				_x = _packet_data.x;
			}
			if (struct_exists(_packet_data, "y")) {
				_y = _packet_data.y;
			}
			
			with (obj_other) {
				if (username == _username) {
					x_input = _x;
					y_input = _y;
					break;
				}
			}
			break;
		
		default:
			break;
	}
}