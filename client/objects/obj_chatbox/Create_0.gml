register_singleton();

log = ds_list_create();
max_to_show = 10;
input_string = "";


add_to_log = function(_message, _color = c_white) {
	ds_list_add(log, {message: _message, color: _color});	
}

my_username = "Anonymous"