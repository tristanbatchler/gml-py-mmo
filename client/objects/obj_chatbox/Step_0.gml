if (input_string != "" and keyboard_check_pressed(vk_enter)) {
	
	// Login
	if (string_starts_with(input_string, "/login ")) {
		var _array = string_split(input_string, " ");
		if (array_length(_array) != 3) {
			add_to_log("Usage: /login username password", c_yellow);
		} else {
			var _username = _array[1];
			var _password = _array[2];
			obj_network_client.send_login(_username, _password);
			my_username = _username;
		}
	}
	
	// Register
	else if (string_starts_with(input_string, "/register ")) {
		var _array = string_split(input_string, " ");
		if (array_length(_array) != 3) {
			add_to_log("Usage: /register username password", c_yellow);
		} else {
			var _username = _array[1];
			var _password = _array[2];
			obj_network_client.send_register(_username, _password);
		}
	}
	
	// Logout
	else if (string_starts_with(input_string, "/logout")) {
		var _array = string_split(input_string, " ");
		if (array_length(_array) != 1) {
			add_to_log("Usage: /logout", c_yellow);
		} else {
			obj_network_client.send_logout(my_username);
		}
	}
	
	// Chat
	else {
		obj_network_client.send_chat(my_username, input_string);
	}
	
	input_string = ""
	keyboard_lastkey = vk_nokey;
	keyboard_lastchar = "";	
}

else if (keyboard_lastkey != vk_nokey) {
    input_string += keyboard_lastchar;
    keyboard_lastkey = vk_nokey;
}