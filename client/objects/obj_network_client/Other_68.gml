var _data_type = async_load[? "type"];

switch (_data_type) {
	case network_type_non_blocking_connect:
		obj_chatbox.add_to_log("Connection established!", c_lime);
		break;
		
	case network_type_data:
		var _buffer = async_load[? "buffer"];
		var _data = SnapBufferReadMessagePack(_buffer, 0);
		var _packet_name = struct_get_names(_data)[0];
		var _packet_data = struct_get(_data, _packet_name);
		
		switch (_packet_name) {
			case "Deny":
				var _reason = _packet_data.reason;
				obj_chatbox.add_to_log("Denied! Reason: " + _reason, c_yellow);
				break;
				
			case "Chat":
				var _sender = _packet_data.sender;
				var _message = _packet_data.message;
				obj_chatbox.add_to_log(_sender + ": " + _message);
				break;
				
			case "Ok":
				if (struct_exists(_packet_data, "message")) {
					obj_chatbox.add_to_log(_packet_data.message, c_lime);
				}
				break;
				
			case "Logout":
				var _username = _packet_data.username;
				obj_chatbox.add_to_log(_username + " has logged out", c_yellow);
				break;
				
			default:
				break;
		}
		
		break;
		
	default:
		break;
}