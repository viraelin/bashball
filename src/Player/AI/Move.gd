extends PlayerAI.AIMode

var distance: = 64.0

func enter() -> void:
	distance = rand_range(60.0, 80.0)

func exit() -> void:
	return

func update(delta: float) -> void:
	if o.BoostCooldown.is_stopped() && o.distance_to_ball >= 470.0:
		o._set_target(o.ball.position)
		o.set_state(o.State.Attack)
		return
		
	var ideal_shot_pos: = predict_futures(delta)
	o._set_target(ideal_shot_pos)
	
	var ball_to_own_goal_dot: = o.ball_direction_to_own_goal.dot(o.ball.linear_velocity.normalized())
	if ball_to_own_goal_dot > 0.0 && o.ball_distance_to_own_goal <= 512.0:
		var radians: = deg2rad(-90.0)
		var dir: = o.ball_direction_to_goal.rotated(radians) * sign(o.ball_direction_to_goal.angle())
		var pos: = o.ball.position + (dir * distance)
		o._set_target(pos)
		
	if o.ball.linear_velocity.length() >= 850.0:
		o._set_target(o.ball_future_pos)
		
	var layer: = 1|2
	var exclude: = [self]
	var result: = o.space_state.intersect_ray(o.ball.position, o.target, exclude, layer, true, false)
	if result:
		var normal: Vector2 = result.normal
		if normal:
			var dir: = o.ball.position.direction_to(o.target).rotated(normal.angle())
			var pos: = o.ball.position + (dir * distance)
			o._set_target(pos)
			
	layer = 2
	var from: = o.ball.position
	var to: = from + (o.direction_to_ball * 2048.0)
	result = o.space_state.intersect_ray(from, to, exclude, layer, true, false)
	if o.BoostCooldown.is_stopped():
		if result:
			if result.collider.team != o.team:
				if attack():
					return
		elif attack():
			return
			
#	Debug.points[1].append(o.target)
	var direction: = o.direction_to_target
	o.move_direction = o.move_direction.linear_interpolate(direction, o.rotation_weight * rand_range(0.72, 1.5)).normalized()

func predict_futures(_delta: float) -> Vector2:
	var dataset: = []
	for data in o.ball.future_data:
		if data.team != o.team:
			if data.shot_bias > 0.899:
#				Debug.multilines[1].append(data.positions)
				dataset.append(data)
				
	var ideal_shot_pos: = o.ball.position
	var most_likely_shot_bias: = 0.0
	var most_likely_shot_data: Ball.FutureData
	for data in dataset:
		if data.shot_bias > most_likely_shot_bias:
			most_likely_shot_bias = data.shot_bias
			most_likely_shot_data = data
			
	if most_likely_shot_data:
		var pos: Vector2
		# hack
		if most_likely_shot_data.positions.size() > 1:
			pos = most_likely_shot_data.positions[-2]
		else:
			pos = most_likely_shot_data.positions[-1]
			
		var direction: = o.ball.position.direction_to(pos)
		ideal_shot_pos -= direction * distance
#		Debug.multilines[2].append(most_likely_shot_data.positions)
	else:
		var shot_direction: = o.get_shot_direction()
		if shot_direction:
			ideal_shot_pos -= shot_direction * distance
			
	return ideal_shot_pos

func attack() -> bool:
	var velocity_dot: = o.linear_velocity.normalized().dot(o.direction_to_target)
	if o.distance_to_target <= 20.0 && velocity_dot <= 0.3:
		o._set_target(o.ball.position)
		o.set_state(o.State.Attack)
		return true
	return false
