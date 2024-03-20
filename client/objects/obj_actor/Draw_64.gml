draw_set_color(c_white);
var _name_height = string_height("@");
var _upper_padding = 2;

var _vpw = view_wport[0];
var _vph = view_hport[0];

var _rw = room_width;
var _rh = room_height;

var _w_factor = _vpw / _rw;
var _h_factor = _vph / _rh;

var _x = (x + sprite_width / 2) * _w_factor;
var _y = y * _h_factor - _name_height - _upper_padding;

draw_set_halign(fa_center);
draw_text(_x, _y, name);