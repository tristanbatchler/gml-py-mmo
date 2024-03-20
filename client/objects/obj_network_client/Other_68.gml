var _data_type = async_load[? "type"];

switch (_data_type) {
	case network_type_non_blocking_connect:
		if async_load[? "succeeded"]{
			obj_chatbox.add_to_log("Connection established!", c_lime);
	    } else {
	        obj_chatbox.add_to_log("Connection failed...", c_yellow);
	    }
		
		break;
		
	case network_type_data:
		var _buffer = async_load[? "buffer"];
		var _data = SnapBufferReadMessagePack(_buffer, 0);
		var _packet_name = struct_get_names(_data)[0];
		var _packet_data = struct_get(_data, _packet_name);
		var _from_pid = pid_to_string(_packet_data.from_pid);
		
		obj_statemachine.state(_packet_name, _packet_data);
		show_debug_message("Got a " + _packet_name + " packet: " + string(_packet_data));
		
		break;
		
	default:
		break;
}