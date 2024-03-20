function get_command(_input_string) {
    var _space_index = string_pos(" ", _input_string);
    if (_space_index != 0)
        return string_copy(_input_string, 1, _space_index - 1);
    return _input_string;
}

function get_args(_input_string) {
	var _command = get_command(_input_string);
	var _headless_input_string = string_replace(_input_string, _command, "");
	return string_split(_headless_input_string, " ", true);
}

function chatbox_process_command(_input_string) {
	var _command = get_command(_input_string);
	var _args = get_args(_input_string);
    switch (_command) {
		case "/help":
			handle_help(_args);
			break;
        case "/login":
            handle_login(_args);
            break;
        case "/register":
            handle_register(_args);
            break;
		case "/logout":
			handle_logout(_args);
			break;
        default:
            obj_network_client.send_packet({
				chat: {
					to_pid: obj_network_client.everyone, 
					message: _input_string	
				}
			});
            break;
    }
}

function handle_help(_args) {
	add_to_log("Start by registering with '/register username password'", c_lime);
	add_to_log("Then you can login with '/login username password'", c_lime);
	add_to_log("Once you're in the game, you can chat freely or logout with '/logout'", c_lime);
	add_to_log("You can view this message again any time with '/help'", c_lime);
}

function handle_login(_args) {
    if (array_length(_args) != 2) {
        add_to_log("Usage: /login username password", c_yellow);
		return;
	}
	if (obj_statemachine.state != state_entry) {
		obj_chatbox.add_to_log("You can't login right now", c_yellow);
		return;	
	}
	
	obj_statemachine.state = state_login;
    obj_network_client.send_packet({
		login: {
			username: _args[0],
			password: _args[1]
		}
	});

}

function handle_register(_args) {
	if (array_length(_args) != 2) {
        add_to_log("Usage: /register username password", c_yellow);
		return;
    }
	if (obj_statemachine.state != state_entry) {
		obj_chatbox.add_to_log("You can't register right now", c_yellow);
		return;	
	}
	
	obj_statemachine.state = state_register;
	obj_network_client.send_packet({
		register: {
			username: _args[0],
			password: _args[1]
		}
	});
}

function handle_logout(_args) {
	if (array_length(_args) != 0) {
		add_to_log("Usage: /logout", c_yellow);	
		return;
	}
	if (obj_statemachine.state != state_play) {
		add_to_log("You can't logout right now", c_yellow);
		return;
	}
	
	obj_statemachine.state = state_entry;
	obj_network_client.send_packet({
		disconnect: {
			to_pid: obj_network_client.everyone,
			reason: "user logged out"
		}
	});
	game_restart();
}