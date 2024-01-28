function player_state_logging_out() {
	switch (_packet_name) {
		case "Ok":
			state = player_state_entry;
			break;
		
		default:
			break;
	}
}