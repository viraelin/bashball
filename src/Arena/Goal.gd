extends Node2D

var team: int # set by instancer

var is_setup: = false
var pips: Array
var color: Color
var pip_count: = 30

onready var GoalArea: Area2D = $Area2D
onready var Particles1: Particles2D = $Particles1
onready var Particles2: Particles2D = $Particles2
onready var ScoreParticles1: Particles2D = $ScoreParticles1
onready var ScoreParticles2: Particles2D = $ScoreParticles2
onready var Score: Node2D = $Score
onready var PipTween: Tween = $PipTween
onready var pip_scene: = preload("res://src/Arena/Pip.tscn")
onready var pip_particles_scene: = preload("res://src/Arena/PipParticles.tscn")

func _ready() -> void:
	$VisibilityNotifier2D.connect("screen_entered", self, "_on_screen_entered")
	$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")

func setup() -> void:
	is_setup = true
	Game.goals.append(self)
	Game.connect("update_score_ui", self, "_on_update_score_ui")
	Game.connect("score_reset", self, "_on_score_reset")
	GoalArea.connect("body_entered", self, "_on_GoalArea_body_entered")
	color = Game.colors[team]
	Particles1.modulate = color
	Particles2.modulate = color
	ScoreParticles1.modulate = color
	ScoreParticles2.modulate = color
	$Light2D.color = color
	$Cover.team = team
	
	var pos: = Score.position
	var pip_separation: = 16
	var chunk_separation: = 80
	var chunk_index_start: = 1
	var chunk_index: = chunk_index_start
	var chunk_limit: = 5
	var flip: = 1
	
	for _i in range(0, pip_count):
		var pip: = pip_scene.instance()
		pip.scale.x = 0.0
		pip.position = pos
		pip.modulate = color
		pip.visible = false
		Score.add_child(pip)
		
		pos.y += pip_separation * chunk_index * flip
		chunk_index += 1
		if chunk_index > chunk_limit:
			pos.y = 0
			pos.x += chunk_separation
			chunk_index = chunk_index_start
			
		flip *= -1
		
	pips = Score.get_children()

func _on_GoalArea_body_entered(_body: Ball) -> void:
	Game.emit_signal("goal_scored", team)
	ScoreParticles1.restart()
	ScoreParticles2.restart()
	Game.emit_signal("screen_shake")
	Effects.shockwave(position)
	var pitch: = rand_range(0.9, 1.1)
	Audio.play("Goal", pitch)
	
	for player in Game.players:
		var direction: = position.direction_to(player.position)
		var impulse: = direction * 1500.0
		player.apply_central_impulse(impulse)

func enable() -> void:
	GoalArea.collision_mask = 4

func disable() -> void:
	GoalArea.collision_mask = 0

func _on_update_score_ui(new: int) -> void:
	if new != team:
		return
		
	var score_value: int = Game.score[team]
	if score_value > pip_count:
		return
		
	var pip: Line2D = pips[score_value - 1]
	var pip_particles: Particles2D = pip_particles_scene.instance()
	pip_particles.modulate = color
	add_child(pip_particles)
	pip_particles.position = pip.global_position
	var x_from: = 0.0
	var x_mid: = 2.0
	var x_to: = 1.0
	var color_from: = color
	var color_to: = color_from
	color_to.a = 0.1
	var duration: = 0.25
	pip.show()
	PipTween.interpolate_property(pip, "scale:x", x_from, x_mid, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	PipTween.interpolate_property(pip, "scale:x", x_mid, x_to, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, duration)
	PipTween.interpolate_property(pip, "modulate", color_from, color_to, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, duration)
	PipTween.start()

func _on_score_reset() -> void:
	for pip in pips:
		pip.scale.x = 0.0
		pip.hide()

func _on_screen_entered() -> void:
	Game.emit_signal("goal_entered_screen", self)

func _on_screen_exited() -> void:
	Game.emit_signal("goal_exited_screen", self)
