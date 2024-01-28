keyboard_buffer += keyboard_string;
keyboard_string = "";

if (keyboard_check_pressed(vk_backspace) and string_length(keyboard_buffer) > 0) {
	if (not alarm[0]) {
		alarm[0] = game_get_speed(gamespeed_fps) * 0.4;
	}
    if (string_length(keyboard_buffer) > 0) {
        keyboard_buffer = string_delete(keyboard_buffer, string_length(keyboard_buffer), 1);
    }
}

if (backspace_repeat and not alarm[1]) {
	alarm[1] = 	game_get_speed(gamespeed_fps) * 0.1;
}

if (keyboard_check_released(vk_backspace)) {
	alarm[0] = -1;	
}

if (keyboard_buffer != "" and keyboard_check_pressed(vk_enter)) {
    chatbox_process_command(keyboard_buffer);
    keyboard_buffer = "";
}