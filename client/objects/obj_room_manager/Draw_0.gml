draw_set_color(c_dkgray);
for (var _x = 0; _x < room_width; _x += xgrid_size) {
	draw_line(_x, 0, _x, room_height);
}

for (var _y = 0; _y < room_height; _y += ygrid_size) {	
	draw_line(0, _y, room_width, _y);
}