/// Call this method in the create event to denote the calling object as a singleton. This will show an error and abort if there is already an existing object of the calling type in the game.
function register_singleton() {
	if (instance_number(object_index) > 1) {
		show_error("Detected multiple objects of same singleton type: " + object_get_name(object_index), true);
	}
}