class_name Math

static func create_polygon(pos: Vector2, vertices: int, radius: float, theta: = -90.0) -> PoolVector2Array:
	theta = deg2rad(theta)
	var poly: PoolVector2Array = []
	for index in vertices:
		var step: = 2.0 * PI * float(index) / vertices + theta
		var x: = pos.x + radius * cos(step)
		var y: = pos.y + radius * sin(step)
		poly.append(Vector2(x, y))
	return poly

static func get_point_on_line(a: Vector2, b: Vector2, pct: float) -> Vector2:
	return a + (b - a) * pct

static func rand_sign() -> int:
	return 1 if randf() > 0.5 else -1

static func get_poly_bounds(poly: PoolVector2Array) -> PoolVector2Array:
	var min_x: = INF
	var min_y: = INF
	var max_x: = -INF
	var max_y: = -INF
	
	for point in poly:
		var x: float = point.x
		var y: float = point.y
		
		if x < min_x:
			min_x = x
		if y < min_y:
			min_y = y
			
		if x > max_x:
			max_x = x
		if y > max_y:
			max_y = y
			
	var bounds: PoolVector2Array = [
		Vector2(min_x, min_y),
		Vector2(max_x, max_y)]
	return bounds

static func get_approx_poly_center(poly: PoolVector2Array) -> Vector2:
	var min_max: = get_poly_bounds(poly)
	var _min: = min_max[0]
	var _max: = min_max[1]
	return (_min + _max) * 0.5
