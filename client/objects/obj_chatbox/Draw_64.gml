draw_set_halign(fa_left);
var _num_messages = ds_list_size(log);
var _num_to_show = min(_num_messages, max_to_show);
var _padding = ceil(string_height("@") * 1.5);

var _vpw = view_wport[0];
var _vph = view_hport[0];

for (var _i = 0; _i < _num_to_show; _i++) {
	var _struct = log[| _num_messages - _num_to_show + _i];
	var _message = _struct.message;
	var _color = _struct.color;
	draw_text_color(10, 10 + _i * _padding, _message, _color, _color, _color, _color, 1);
}

draw_set_color(c_white);
draw_rectangle(10, _vph - 10 - _padding, _vpw - 10, _vph - 10, true);

var _prompt = keyboard_buffer;
if (blink) {
	_prompt += "|";
}

draw_text(10 + 3, _vph - 10 - _padding + 3, _prompt);
