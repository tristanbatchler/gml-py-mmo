var _num_messages = ds_list_size(log);
var _num_to_show = min(_num_messages, max_to_show);

for (var _i = 0; _i < _num_to_show; _i++) {
	var _struct = log[| _num_messages - _num_to_show + _i];
	var _message = _struct.message;
	var _color = _struct.color;
	draw_text_color(10, 10 + _i * 50, _message, _color, _color, _color, _color, 1);
}

draw_rectangle(10, 20 + max_to_show * 50, room_width - 10, 70 + max_to_show * 50, true);
draw_text(20, 30 + max_to_show * 50, input_string);