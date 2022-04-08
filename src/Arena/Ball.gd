extends RigidBody2D
class_name Ball

var velocity_trail_threshold: = 800.0
var velocity_shockwave_threshold: = 992.0
var velocity_squish_threshold: = 625.0
var color: = Color("dbdbdb")
var space_state: Physics2DDirectSpaceState
var future_data: = []
var actual_future: FutureData

onready var Trail: Line2D = $Trail
onready var Animator: AnimationPlayer = $Animator
onready var Body: Node2D = $Body
onready var start_position: = position
onready var radius: float = $CollisionShape2D.shape.radius

func _ready() -> void:
	space_state = get_world_2d().direct_space_state
	Game.ball = self
	
	connect("body_entered", self, "_on_body_entered")
	
	$Body/Outline.default_color = color
	Trail.modulate = color
	$LightOccluder2D.occluder.polygon = $Body/Fill.polygon

func _physics_process(delta: float) -> void:
	var impulse: = 1024.0
	var vertices: = 64 # accuracy
	var polygon_radius: = 64.0
	var points: = Math.create_polygon(position, vertices, polygon_radius)
	var dataset: = []
#	Debug.points[0].append_array(points)
	for point in points:
		var vel: = position.direction_to(point) * -impulse
		var data: = lookahead(delta, vel)
		dataset.append(data)
		
	actual_future = lookahead(delta, linear_velocity)
	future_data = dataset
	
	if Trail.is_active:
		Effects.trail(position, linear_velocity.normalized(), color, "64h")
		
	if linear_velocity.length() > velocity_trail_threshold && !Trail.is_active:
		Trail.start()

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	var contact_count: = state.get_contact_count()
	if contact_count > 0:
		for id in range(0, contact_count):
			var pos: = state.get_contact_local_position(id)
			var normal: = state.get_contact_local_normal(id)
			Effects.spark(pos, normal, color, "64h")

func enable() -> void:
	mode = MODE_CHARACTER
	set_physics_process(true)

func disable() -> void:
	set_physics_process(false)
	Trail.clear_points()
	mode = MODE_KINEMATIC
	linear_velocity = Vector2.ZERO

func reset() -> void:
	position = start_position
	Body.rotation = 0

func _on_body_entered(body: Node2D) -> void:
	Body.rotation = linear_velocity.normalized().angle()
	
	if linear_velocity.length() > velocity_shockwave_threshold:
		Effects.shockwave(position)
		Game.emit_signal("screen_shake")
		
	if linear_velocity.length() > velocity_squish_threshold:
		Animator.play("squish")
		
	if body.name.begins_with("Player"):
		pass
	else:
		var pitch: = rand_range(1.3, 1.6)
		var volume: = linear_velocity.length() * 0.01
		Audio.play("HitWall", pitch, volume)
		
	if linear_velocity.length() > velocity_trail_threshold:
		Trail.start()

class FutureData:
	var pos: Vector2
	var positions: = []
	var shot_bias: = 0.0
	var team: = -1

func lookahead(delta: float, vel: = linear_velocity) -> FutureData:
	var pos: = position
	var offset: = radius
	var bounces: = 4
	
	var from: = pos
	delta *= 60
	vel *= delta
	pos += vel
	var to: = pos
	
	var data: = FutureData.new()
	data.pos = to
	
	var layer: = 1|2|4|8
	var rid: = get_rid()
	var exclude: = [self]
	var xform: = transform
	var infinite_intertia: = false
	var exclude_raycast: = true
	var margin: = 0.08
	var result: = Physics2DTestMotionResult.new()
	
	for i in range(0, bounces):
		var has_collided: = Physics2DServer.body_test_motion(rid, xform, vel, infinite_intertia, margin, result, exclude_raycast, exclude)
		if has_collided:
			if result.collision_normal == Vector2.ZERO:
				break
				
			var off: = result.collision_normal * offset
			vel -= result.motion
			vel = vel.bounce(result.collision_normal)
			var new: = result.collision_point + off
			data.positions.append(from)
			data.positions.append(new)
			
			var new_from: = new
			var new_to: = new + vel
			from = new_from
			to = new_to
			data.pos = new_to
			
			var goal_result: = space_state.intersect_ray(from, to, exclude, layer, true, false)
			if goal_result && goal_result.collider.collision_layer == 2:
				var collider: Node2D = goal_result.collider
				var shot_bias: = 1.0
				# favor fewer bounces
				shot_bias -= i * 0.1
				# favor goal center
				var distance: = collider.global_position.distance_to(from)
#				Debug.points[2].append(collider.global_position)
				shot_bias -= (distance * 0.0001)
				shot_bias = clamp(shot_bias, 0.0, 1.0)
				data.shot_bias = shot_bias
				data.team = collider.team
				data.positions.append(from)
				data.positions.append(to)
				data.pos = to
				break

		else:
			data.positions.append(from)
			data.positions.append(to)
			
	return data
