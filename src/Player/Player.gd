extends RigidBody2D
class_name Player

var id: int
var team: int

var velocity_max: = 2000.0
var speed: = 60.0
var boost_factor: = 1000.0
var velocity_shockwave_threshold: = 900.0
var rotation_weight: = 0.33
var has_hit_ball_with_boost: = false
var origin_weight: = 0.8
var boost_wait_time_reduction: = 0.25
var keyboard_turn_speeds: = [
	deg2rad(1.0),
	deg2rad(2.0),
	deg2rad(3.0),
	deg2rad(4.0),
	deg2rad(5.0),
	deg2rad(6.0),
	deg2rad(7.0),
	deg2rad(8.0),
	deg2rad(9.0),
	deg2rad(10.0),
]
var keyboard_turn_speed_default_index: = 5
var keyboard_turn_speed: float = keyboard_turn_speeds[keyboard_turn_speed_default_index - 1]

var action_left: String
var action_right: String
var action_up: String
var action_down: String
var action_boost: String
var action_left_kb: String
var action_right_kb: String
var action_up_kb: String
var action_boost_kb: String
var color: Color
var InputHandler: Node
var vertices: = 4

onready var HitCooldown: Timer = $HitCooldown
onready var BoostCooldown: Timer = $BoostCooldown
onready var BoostRechargeAnimator: AnimationPlayer = $BoostRecharge/Animator
onready var Animator: AnimationPlayer = $Animator
onready var Body: Node2D = $Body
onready var Trail: Line2D = $Trail
onready var Origin: Node2D = $Origin
onready var InputHandlerController: = $PlayerControllerInput
onready var InputHandlerKeyboard: = $PlayerKeyboardInput
onready var NumberLabel: Node2D = $NumberLabel

onready var start_position: = position
onready var start_rotation: = rotation

func _ready() -> void:
	Game.players.append(self)
	
	InputHandler = InputHandlerController
	
	action_left = "%s_left" % id
	action_right = "%s_right" % id
	action_up = "%s_up" % id
	action_down = "%s_down" % id
	action_boost = "%s_boost" % id
	
	if id in [0, 1]:
		action_left_kb = "%s_left_kb" % id
		action_right_kb = "%s_right_kb" % id
		action_up_kb = "%s_up_kb" % id
		action_boost_kb = "%s_boost_kb" % id
		
		var last_input_type: int = Game._last_input_type[id]
		if last_input_type == InputType.Controller:
			InputHandler = InputHandlerController
		elif last_input_type == InputType.Keyboard:
			InputHandler = InputHandlerKeyboard
			
		var turn_speed: int = Game.options_config.get_value("options", "P%sKeyboardSpeed" % (id + 1), keyboard_turn_speed_default_index)
		_set_keyboard_turn_speed(turn_speed - 1)
		
	connect("body_entered", self, "_on_body_entered")
	BoostCooldown.connect("timeout", self, "_on_BoostCooldown_timeout")
	
	color = Game.colors[team]
	$Body/Outline.default_color = color
	$Origin/Pointer.default_color = color
	$Origin/Fill.color = color
	$Light2D.color = color
	$LightOccluder2D.occluder.polygon = $Body/Fill.polygon
	$BoostRecharge.modulate = color
	NumberLabel.get_node("Label").text = "%s" % (id + 1)
	
	Game.connect("options_set_labels_state", self, "_on_options_set_labels_state")
	Game.connect("options_turn_speed_changed", self, "_on_options_turn_speed_changed")
	
	var label_state: bool = Game.options_config.get_value("options", "Labels", true)
	NumberLabel.visible = label_state
	Trail.modulate = color
	Origin.set_as_toplevel(true)
	Origin.position = position
	Origin.rotation = rotation
	NumberLabel.set_as_toplevel(true)
	NumberLabel.position = position
	NumberLabel.modulate = color
	mode = MODE_KINEMATIC

func _input(event: InputEvent) -> void:
	handle_input(event)

func handle_input(event: InputEvent) -> void:
	_set_input_handler(event)
	InputHandler.handle_input(event)

func _set_input_handler(event: InputEvent) -> void:
	if id in [0, 1]:
		if InputHandler.type == InputType.Keyboard && (event is InputEventJoypadButton || event is InputEventJoypadMotion):
			if event.device == id:
				InputHandler = InputHandlerController
		elif InputHandler.type == InputType.Controller && \
			(event.is_action_pressed(action_left_kb) || \
			event.is_action_pressed(action_right_kb) || \
			event.is_action_pressed(action_up_kb) || \
			event.is_action_pressed(action_boost_kb)):
				InputHandler = InputHandlerKeyboard

func _physics_process(delta: float) -> void:
	process(delta)

func process(_delta: float) -> void:
	var direction: Vector2 = InputHandler.get_direction()
	rotation = InputHandler.get_rotation(direction)
	
	var impulse: = direction * speed
	apply_central_impulse(impulse)
	
	Origin.position = lerp(Origin.position, position, origin_weight)
	Origin.rotation = rotation
	NumberLabel.position = position
	
	if BoostCooldown.time_left > BoostCooldown.wait_time - boost_wait_time_reduction:
		Effects.trail(position, linear_velocity.normalized(), color, "%sh" % [vertices])

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	var contact_count: = state.get_contact_count()
	if contact_count > 0:
		for contact in range(0, contact_count):
			var pos: = state.get_contact_local_position(contact)
			var normal: = state.get_contact_local_normal(contact)
			Effects.spark(pos, normal, color, "%sh" % [vertices])

func try_to_boost() -> void:
	if BoostCooldown.is_stopped():
		var direction: Vector2 = InputHandler.get_boost_direction()
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

func _on_BoostCooldown_timeout() -> void:
	Trail.stop()
	has_hit_ball_with_boost = false

func enable() -> void:
	mode = MODE_CHARACTER
	set_process_input(true)
	set_physics_process(true)

func disable() -> void:
	set_process_input(false)
	set_physics_process(false)
	Trail.stop()
	Trail.clear_points()
	mode = MODE_KINEMATIC
	linear_velocity = Vector2.ZERO

func reset() -> void:
	position = start_position
	rotation = start_rotation
	Origin.position = position
	Origin.rotation = rotation
	NumberLabel.position = position
	BoostCooldown.stop()
	HitCooldown.stop()
	advance_boost_recharge_animation()
	BoostRechargeAnimator.stop()
	has_hit_ball_with_boost = false

func advance_boost_recharge_animation() -> void:
	if BoostRechargeAnimator.is_playing():
		var time: = BoostRechargeAnimator.current_animation_position
		var duration: = BoostRechargeAnimator.current_animation_length
		var delta: = duration - time
		BoostRechargeAnimator.advance(delta)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		Game.report_ball_contact(team)
		if !BoostCooldown.is_stopped() && !has_hit_ball_with_boost:
			if body.linear_velocity.length() >= velocity_shockwave_threshold:
				has_hit_ball_with_boost = true
				var direction: = position.direction_to(body.position)
				var additional_impulse: = linear_velocity * direction * 0.294
				body.apply_central_impulse(additional_impulse)
#				Game.emit_signal("timed_pause", 0.05)
				Game.emit_signal("screen_shake")
				var pitch: = rand_range(1.3, 1.6)
				var volume: = 10.0
				Audio.play("Hit", pitch, volume)
				return
		var pitch: = rand_range(0.97, 1.3)
		Audio.play("Hit", pitch)
	else:
		var pitch: = rand_range(0.95, 1.4)
		Audio.play("HitWall", pitch)

func _on_options_set_labels_state(state: bool) -> void:
	NumberLabel.visible = state

func _on_options_turn_speed_changed(_id: int, value: int) -> void:
	if id == _id:
		_set_keyboard_turn_speed(value)

func _set_keyboard_turn_speed(value: int) -> void:
	if value >= 0 && value < keyboard_turn_speeds.size():
		keyboard_turn_speed = keyboard_turn_speeds[value]
	else:
		keyboard_turn_speed = keyboard_turn_speeds[keyboard_turn_speed_default_index]

func set_shape(type: int) -> void:
	var data: = Game.set_shape(Body, Origin, type)
	vertices = data[0]
	
	if type != 0:
		var recharge_fill: = $BoostRecharge/PolygonCreator
		var recharge_outline: = $BoostRecharge/OutlineCreator
		recharge_fill.set_vertices(data[0])
		recharge_fill.set_angle(data[1])
		recharge_fill.set_radius(data[2])
		recharge_outline.set_vertices(data[0])
		recharge_outline.set_angle(data[1])
		recharge_outline.set_radius(data[2])
		
	if type == 1:
		var shape: = ConvexPolygonShape2D.new()
		shape.points = $Body/Fill.polygon
		var shape_owner_id: = 0
		shape_owner_clear_shapes(shape_owner_id)
		shape_owner_add_shape(shape_owner_id, shape)
		$LightOccluder2D.occluder.polygon = $Body/Fill.polygon
	elif type == 2:
		var shape: = CircleShape2D.new()
		shape.radius = data[2]
		var shape_owner_id: = 0
		shape_owner_clear_shapes(shape_owner_id)
		shape_owner_add_shape(shape_owner_id, shape)
		$LightOccluder2D.occluder.polygon = $Body/Fill.polygon
