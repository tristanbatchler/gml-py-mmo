if (state != player_state_play) {
	return;	
}

var _x_input = keyboard_check(vk_right) - keyboard_check(vk_left);
var _y_input = keyboard_check(vk_down) - keyboard_check(vk_up);

x += _x_input * move_speed;
y += _y_input * move_speed;

if (_x_input != prev_x_input and _y_input != prev_y_input) {
	obj_network_client.send_move(username, _x_input, _y_input);	
} else if (_x_input != prev_x_input) {
	obj_network_client.send_move(username, _x_input);
} else if (_y_input != prev_y_input) {
	obj_network_client.send_move(username,         , _y_input);
}

prev_x_input = _x_input;
prev_y_input = _y_input;