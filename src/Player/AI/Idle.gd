extends PlayerAI.AIMode

func enter() -> void:
	return

func exit() -> void:
	return

func update(_delta: float) -> void:
	o._set_target(o.home_pos)
	
	if o.distance_to_target <= 64.0:
		o.move_speed = 0.0
		o.move_direction = o.direction_to_ball
	else:
		o.move_direction = o.move_direction.linear_interpolate(o.direction_to_target, o.rotation_weight).normalized()
	
	if o.distance_to_ball <= 600.0:
		o.set_state(o.initial_state)
