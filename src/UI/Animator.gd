extends Control

signal finished

onready var Animator: AnimationPlayer = $Animator

func _ready() -> void:
	pass

func start() -> void:
	Animator.play("start")

func _finished() -> void:
	emit_signal("finished")
