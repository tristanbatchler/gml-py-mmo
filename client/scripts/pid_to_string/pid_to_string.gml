function pid_to_string(_pid) {
	var _bytes_array = _pid.data;
	var _b64_buffer = buffer_create(16, buffer_fixed, 1);
	for (var _i = 0; _i < array_length(_bytes_array); _i++) {
		buffer_write(_b64_buffer, buffer_u8, _bytes_array[_i]);	
	}
	return buffer_base64_encode(_b64_buffer, 0, 16);
}