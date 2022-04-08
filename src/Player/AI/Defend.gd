extends PlayerAI.AIMode

func enter() -> void:
	return

func exit() -> void:
	return

func update(_delta: float) -> void:
	if o.distance_to_own_goal >= 256.0:
		if o.distance_to_ball <= 128.0:
			var direction: = o.get_shot_direction()
			var dist: = 64.0
			if direction:
				var pos: = o.ball.position - direction * dist
				o._set_target(pos)
				
			if o.distance_to_target <= 64.0:
				o.set_state(o.State.Attack)
				return
		else:
			o._set_target(o.own_goal.position)
	else:
		if o.distance_to_ball >= 600.0:
			o.set_state(o.State.Idle)
			return
		else:
			o._set_target(o.ball.position)
			
	o.move_direction = o.move_direction.linear_interpolate(o.direction_to_target, o.rotation_weight * rand_range(0.72, 1.5)).normalized()
