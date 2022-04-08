extends PlayerAI.AIMode

func enter() -> void:
	o.move_direction = o.direction_to_target
	o.boost(o.move_direction)

func exit() -> void:
	return

func update(_delta: float) -> void:
#	o._set_target(o.ball_future_pos)
	o._set_target(o.ball.position)
	o.move_direction = o.move_direction.linear_interpolate(o.direction_to_target, o.rotation_weight).normalized()
	if o.BoostCooldown.is_stopped():
		o.set_state(o.state_history[1])
