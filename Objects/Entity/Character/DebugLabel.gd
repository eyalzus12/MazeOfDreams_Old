extends Label

func update_text(ch: Character) -> void:
	if not is_instance_valid(ch): return
	text =  str( \
		"left: ", ch.left,\
		" right: ", ch.right,\
		" up: ", ch.up,\
		" down: ", ch.down,\
		" input vector: ", ch.input_vector,\
		" velocity vector: ", ch.velocity_vector,\
		"\n",\
		"hp: ", ch.current_hp,\
		"\n",\
		"state: ", ch.current_state,\
		" state frame: ", ch.state_frame,\
		"\n",\
		"dash in cooldown: ", ch.dash_in_cooldown,\
		" in dash: ", ch.in_dash,\
		"\n",\
		"velocity: ", ch.velocity,\
		" position: ", ch.position,\
		"\n",\
		"on wall: ", ch.is_on_wall(),\
		" collision normal: ", Vector2.ZERO if ch.get_slide_collision_count() <= 0 else ch.get_slide_collision(0).get_normal(),\
		"\n",\
		"FPS: ", Engine.get_frames_per_second(),\
		"\n"\
	)
