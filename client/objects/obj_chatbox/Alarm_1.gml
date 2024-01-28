///@description Fires every 0.1 seconds while backspace repeat is on
if (string_length(keyboard_buffer) <= 0) {
	alarm[1] = -1;	
	backspace_repeat = false;
	return;
}

keyboard_buffer = string_delete(keyboard_buffer, string_length(keyboard_buffer), 1);
if (backspace_repeat) {
	alarm[1] = game_get_speed(gamespeed_fps) * 0.1;	
}