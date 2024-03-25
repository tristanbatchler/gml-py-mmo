extends StateScene

func _on_packet_received(p_type: String, p_data: Dictionary):	
	if p_type == "Ok":
		UI.add_to_log("Registration succeeded! Now go and login with your new account.", UI.GREEN)
		get_tree().change_scene_to_file("res://scenes/entry.tscn")
	elif p_type == "Deny":
		UI.add_to_log("Registration failed failed... %s" % p_data["reason"], UI.YELLOW)
		get_tree().change_scene_to_file("res://scenes/entry.tscn")
