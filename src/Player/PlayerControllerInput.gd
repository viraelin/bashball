extends Node

var type: = InputType.Controller

onready var player: Player = get_parent()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(player.action_boost):
		player.try_to_boost()

func get_direction() -> Vector2:
	var direction: = Input.get_vector(player.action_left, player.action_right, player.action_up, player.action_down)
	return direction

func get_rotation(direction: Vector2) -> float:
	if direction:
		var angle: = direction.angle()
		var rotation: = lerp_angle(player.rotation, angle, player.rotation_weight)
		return rotation
	return player.rotation

func get_boost_direction() -> Vector2:
	var direction: = get_direction().normalized()
	if direction.is_equal_approx(Vector2.ZERO):
		direction = Vector2(cos(player.rotation), sin(player.rotation)).normalized()
	return direction
