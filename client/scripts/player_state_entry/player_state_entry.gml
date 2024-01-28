function player_state_entry(_packet_name, _packet_data) {
	switch (_packet_name) {
		case "Ok":
			state = player_state_play;
			break;
		
		default:
			break;
	}
}