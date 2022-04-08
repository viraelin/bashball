extends Player
class_name PlayerAI

var move_direction: = Vector2.ZERO
var is_active: = false
var move_speed: = speed

var space_state: Physics2DDirectSpaceState
var ball: Ball
var goals: Array
var goal: Node2D
var direction_to_ball: Vector2
var distance_to_ball: float
var ball_future_pos: Vector2
var direction_to_ball_future_pos: Vector2
var distance_to_ball_future_pos: float
var direction_to_goal: Vector2
var distance_to_goal: float
var target: Vector2
var direction_to_target: Vector2
var distance_to_target: float
var ball_direction_to_goal: Vector2
var ball_distance_to_goal: float
var enemy_player: Player
var own_goal: Node2D
var direction_to_own_goal: Vector2
var distance_to_own_goal: float
var ball_direction_to_own_goal: Vector2
var ball_distance_to_own_goal: float
var home_pos: Vector2

var initial_state: int = State.Move
var current_state: AIState
var state_history: = []
var state_history_limit: = 3

enum State {
	Idle,
	Move,
	Attack,
	Defend,
#	Bully,
}

onready var states: = {
	State.Idle: $States/Idle,
	State.Move: $States/Move,
	State.Attack: $States/Attack,
	State.Defend: $States/Defend,
#	State.Bully: $States/Bully,
}
onready var StateTimer: Timer = $StateTimer
onready var DisableTimer: Timer = $DisableTimer
onready var linear_damp_default: = linear_damp

func _ready() -> void:
	for key in states:
		var state: AIState = states[key]
		state.o = self
		
	current_state = states[initial_state]
	state_history.append(initial_state)
	
	randomize()
	DisableTimer.connect("timeout", self, "_on_DisableTimer_timeout")
	Game.connect("goal_scored", self, "_on_goal_scored")
	space_state = get_world_2d().direct_space_state
	goals = Game.goals.duplicate()
	var pattern: = "Goal%s" % (team + 1)
	for local_goal in goals:
		if local_goal.name == pattern:
			own_goal = local_goal
			goals.erase(local_goal)
			break
			
	NumberLabel.hide()

func handle_input(_event: InputEvent) -> void:
	return

func process(delta: float) -> void:
	if is_active:
		_set_ball()
		_set_ball_future()
		_set_goal()
		move_speed = speed
		current_state.update(delta)
	else:
		move_direction = Vector2(cos(rotation), sin(rotation))
		move_speed = 0.0
		
	var angle: = move_direction.angle()
	rotation = lerp_angle(rotation, angle, rotation_weight)
	var impulse: = move_direction * move_speed
	apply_central_impulse(impulse)
	Origin.position = lerp(Origin.position, position, origin_weight)
	Origin.rotation = rotation
	NumberLabel.position = position
	if BoostCooldown.time_left > BoostCooldown.wait_time - boost_wait_time_reduction:
		Effects.trail(position, linear_velocity.normalized(), color, "4h")

func _on_options_set_labels_state(_state: bool) -> void:
	return

func boost(direction: Vector2) -> void:
	if BoostCooldown.is_stopped():
		var impulse: = direction * boost_factor
		apply_central_impulse(impulse)
		HitCooldown.stop()
		BoostCooldown.start()
		Trail.start()
		advance_boost_recharge_animation()
		BoostRechargeAnimator.play("boost_recharge")
		Animator.play("squish")
		var pitch: = rand_range(0.9, 1.1)
		Audio.play("Boost", pitch)

func _set_target(pos: Vector2) -> void:
	target = pos
	direction_to_target = position.direction_to(pos)
	distance_to_target = position.distance_to(pos)

func _set_ball() -> void:
	ball = Game.ball
	direction_to_ball = position.direction_to(ball.position)
	distance_to_ball = position.distance_to(ball.position)

func _set_ball_future() -> void:
	ball_future_pos = ball.actual_future.pos
	direction_to_ball_future_pos = position.direction_to(ball_future_pos)
	distance_to_ball_future_pos = position.distance_to(ball_future_pos)
#	Debug.multilines[1].append(data.positions)

func _set_goal() -> void:
	var local_distance_to_goal: = INF
	var nearest_goal: Node2D
	for local_goal in goals:
		var dist: = position.distance_squared_to(local_goal.position)
		if dist < local_distance_to_goal:
			local_distance_to_goal = dist
			nearest_goal = local_goal
			
	direction_to_goal = position.direction_to(nearest_goal.position)
	distance_to_goal = position.distance_to(nearest_goal.position)
	ball_direction_to_goal = ball.position.direction_to(nearest_goal.position)
	ball_distance_to_goal = ball.position.distance_to(nearest_goal.position)
	goal = nearest_goal
	direction_to_own_goal = position.direction_to(own_goal.position)
	distance_to_own_goal = position.distance_to(own_goal.position)
	ball_direction_to_own_goal = ball.position.direction_to(own_goal.position)
	ball_distance_to_own_goal = ball.position.distance_to(own_goal.position)
	
	var r: = own_goal.rotation
	home_pos = own_goal.position + (Vector2(cos(r), sin(r)) * 128.0)

func get_shot_direction(from: = ball.position) -> Vector2:
	var layer: = 8
	var dir: = ball_direction_to_goal
	var angle: = 0.1
	var angle_step: = 0.1
	var exclude: = [self]
	var direction: = Vector2()
	for _i in range(0, 16):
		var to: = from + (dir * 1024.0)
		var result: = space_state.intersect_ray(from, to, exclude, layer)
		if result:
#			Debug.lines[1].append([from, to])
			dir = dir.rotated(angle)
			angle += angle_step
			angle *= -1
			continue
		else:
#			Debug.lines[2].append([from, to])
			direction = from.direction_to(to)
			break
	return direction

func _set_random_player() -> void:
	var players: = Game.players.duplicate()
	var ps: = []
	for i in range(0, players.size()):
		var player: Player = players[i]
		if player.team != team:
			ps.append(player)
	if ps.size() > 0:
		enemy_player = ps[randi() % ps.size()]

func enable() -> void:
	is_active = true
	.enable()

func disable() -> void:
	is_active = false
	DisableTimer.stop()
	.disable()

func _on_goal_scored(_value: int) -> void:
	DisableTimer.start(rand_range(0.1, 0.9))

func _on_DisableTimer_timeout() -> void:
	is_active = false

func set_state(state: int) -> void:
	current_state.exit()
	state_history.push_front(state)
	if state_history.size() > state_history_limit:
		state_history.pop_back()
	current_state = states[state]
	current_state.enter()

class AIState:
	extends Node
	func enter() -> void:
		return
	func exit() -> void:
		return
	func update(_delta: float) -> void:
		return

class AIMode:
	extends AIState
	var o: PlayerAI
