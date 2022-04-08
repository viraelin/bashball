extends Camera2D

var zoom_min: = 1.0

onready var zoom_max: = zoom.x

func _ready() -> void:
	Game.current_camera = self

func _physics_process(_delta: float) -> void:
	var ball_pos: = Game.ball.global_position
	var positions: = [ball_pos]
	var total_distance: = 0.0
	var count: = Game.players.size()
	
	for player in Game.players:
		var player_pos: Vector2 = player.global_position
		var distance: = player_pos.distance_to(ball_pos)
		total_distance += distance
		positions.append(player_pos)
		
	var average_position: = Math.get_approx_poly_center(positions)
#	Debug.points[2].append(average_position)
	position = average_position
	var distance_max: = 1000.0
	var average_distance: = total_distance / count
	average_distance = average_distance/distance_max
	average_distance *= 5.0
	average_distance = clamp(average_distance, zoom_min, zoom_max)
	
	var z: float = lerp(zoom.x, average_distance, 0.1)
	zoom.x = z
	zoom.y = z
