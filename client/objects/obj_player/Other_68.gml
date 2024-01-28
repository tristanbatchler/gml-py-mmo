var _data_type = async_load[? "type"];

if (_data_type != network_type_data) {
	return;
}

var _buffer = async_load[? "buffer"];
var _data = SnapBufferReadMessagePack(_buffer, 0);
var _packet_name = struct_get_names(_data)[0];
var _packet_data = struct_get(_data, _packet_name);

state(_packet_name, _packet_data);