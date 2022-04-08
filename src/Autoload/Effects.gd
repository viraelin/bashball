extends Node2D

var _shockwave_scene: = preload("res://src/Effects/Shockwave.tscn")
var _screen_transition_fade_scene: = preload("res://src/Effects/ScreenTransitionFade.tscn")
var _screen_transition_pixel_scene: = preload("res://src/Effects/ScreenTransitionPixel.tscn")
var _countdown_scene: = preload("res://src/UI/Countdown.tscn")
var _overtime_scene: = preload("res://src/UI/Overtime.tscn")
var _spark_particles_scene: = preload("res://src/Effects/SparkParticles.tscn")
var _trail_particles_scene: = preload("res://src/Effects/TrailParticles.tscn")
var _time_slow_scene: = preload("res://src/Effects/TimeSlowTween.tscn")

var textures: = {
	"3h": preload("res://res/particles/3h.png"),
	"3s": preload("res://res/particles/3s.png"),
	"4h": preload("res://res/particles/4h.png"),
	"4s": preload("res://res/particles/4s.png"),
	"64h": preload("res://res/particles/64h.png"),
	"64s": preload("res://res/particles/64s.png"),
}

onready var _Overlay: CanvasLayer = $Overlay
onready var _ScreenTransitions: CanvasLayer = $ScreenTransitions
onready var _Particles: Node2D = $Particles

var spark_count: = 0
var spark_threshold: = 64
var spark_limit: = 256
var sparks: = []

func _ready() -> void:
	for _i in range(0, spark_limit):
		var instance: Particles2D = _spark_particles_scene.instance()
		_Particles.add_child(instance)
		sparks.append(instance)

func shockwave(pos: Vector2) -> void:
	var instance: Node2D = _shockwave_scene.instance()
	instance.parent = self
	instance.target = pos
	instance.duration = 0.75
	instance.size = 2.0
	_Overlay.add_child(instance)

func screen_transition_fade() -> Node:
	var instance: Node = _screen_transition_fade_scene.instance()
	_ScreenTransitions.add_child(instance)
	return instance

func screen_transition_pixel() -> Node:
	var instance: Node = _screen_transition_pixel_scene.instance()
	_ScreenTransitions.add_child(instance)
	return instance

func countdown() -> Node:
	var instance: Node = _countdown_scene.instance()
	_Overlay.add_child(instance)
	return instance

func overtime() -> Node:
	var instance: Node = _overtime_scene.instance()
	_Overlay.add_child(instance)
	return instance

func spark(pos: Vector2, direction: Vector2, color: Color, texture: String) -> void:
	# spark_count is changed from spark object
	if spark_count >= spark_limit:
		return
		
	var instance: Particles2D
	for spark in sparks:
		if !spark.is_active:
			instance = spark
			break
			
	if !instance:
		return
		
	if spark_count > spark_threshold:
		instance.lifetime = 0.25
	else:
		instance.lifetime = 1.25
		
	instance.position = pos
	instance.process_material.direction = Vector3(direction.x, direction.y, 0)
	instance.modulate = color
	instance.texture = textures.get(texture)
	instance.start()

func trail(pos: Vector2, direction: Vector2, color: Color, texture: String) -> void:
	var instance: Particles2D = _trail_particles_scene.instance()
	instance.position = pos
	instance.process_material.direction = Vector3(direction.x, direction.y, 0)
	instance.modulate = color
	instance.texture = textures.get(texture)
	add_child(instance)

func slow(duration: = 0.5) -> Tween:
	var instance: Tween = _time_slow_scene.instance()
	instance.duration = duration
	add_child(instance)
	return instance
