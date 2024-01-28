register_singleton();

log = ds_list_create();
max_to_show = 5;

keyboard_buffer = "";
backspace_repeat = false;

add_to_log = function(_message, _color = c_white) {
	ds_list_add(log, {message: _message, color: _color});	
}

draw_set_font(fnt_main);

blink = false;
alarm[2] = game_get_speed(gamespeed_fps) * 0.5;