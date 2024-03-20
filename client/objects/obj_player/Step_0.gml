var _dx = 0;
var _dy = 0;

if (keyboard_check_released(vk_right)) {
	_dx = obj_room_manager.xgrid_size;
} else if (keyboard_check_released(vk_left)) {
	_dx = -obj_room_manager.xgrid_size;	
} else if (keyboard_check_released(vk_down)) {
	_dy = obj_room_manager.xgrid_size;	
} else if (keyboard_check_released(vk_up)) {
	_dy = -obj_room_manager.xgrid_size;	
}

if (_dx != 0 || _dy != 0) {
	obj_network_client.send_packet({
		move: {
			dx: _dx,
			dy: _dy
		}
	});	
}