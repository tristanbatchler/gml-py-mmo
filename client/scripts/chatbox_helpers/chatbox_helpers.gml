function get_command(_input_string) {
    var _space_index = string_pos(" ", _input_string);
    if (_space_index != 0)
        return string_copy(_input_string, 1, _space_index - 1);
    return _input_string;
}

function chatbox_process_command(_input_string) {
	var command = get_command(_input_string);
    switch (command) {
        case "/login":
            handle_login(_input_string);
            break;
        case "/register":
            handle_register(_input_string);
            break;
        case "/logout":
            handle_logout(_input_string);
            break;
        default:
            obj_network_client.send_chat(obj_player.username, _input_string);
            break;
    }
}

function handle_login(_input_string) {
	var _array = string_split(_input_string, " ");
    if (array_length(_array) != 3) {
        add_to_log("Usage: /login username password", c_yellow);
    } else {
        var _username = _array[1];
        var _password = _array[2];
        obj_network_client.send_login(_username, _password);
        obj_player.username = _username;
    }
}

function handle_logout(_input_string) {
    var _array = string_split(_input_string, " ");
    if (array_length(_array) != 1) {
        add_to_log("Usage: /logout", c_yellow);
    } else {
        obj_network_client.send_logout(obj_player.username);
        obj_player.state = player_state_logging_out;
    }
}