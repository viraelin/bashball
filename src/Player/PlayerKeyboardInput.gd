extends Node

var type: = InputType.Keyboard

onready var player: Player = get_parent()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(player.action_boost_kb):
		player.try_to_boost()

func get_direction() -> Vector2:
	if Input.is_action_pressed(player.action_up_kb):
		var direction: = Vector2(cos(player.rotation), sin(player.rotation)).normalized()
		return direction
	return Vector2()

func get_rotation(_direction: Vector2) -> float:
	var turn_left: = int(Input.is_action_pressed(player.action_left_kb))
	var turn_right: = int(Input.is_action_pressed(player.action_right_kb))
	var turn_direction: = turn_right - turn_left
	if turn_direction in [-1, 1]:
		var rotation: = player.rotation + (player.keyboard_turn_speed * turn_direction)
		return rotation
	return player.rotation

func get_boost_direction() -> Vector2:
	var direction: = Vector2(cos(player.rotation), sin(player.rotation)).normalized()
	return direction
