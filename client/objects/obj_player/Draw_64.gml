if (state == player_state_play) {
	var _x_scale = view_wport[view_current] / room_width;
	var _y_scale = view_hport[view_current] / room_height;

	var _x = x * _x_scale + sprite_width / 2 + string_width(username) / 2;
	var _y = y * _y_scale - string_height(username) - 5;

	draw_text_color(_x, _y , username, c_lime, c_lime, c_lime, c_lime, 1);	
}