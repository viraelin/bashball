extends Node2D

onready var IdleTween: Tween = $IdleTween

func _ready() -> void:
	IdleTween.connect("tween_all_completed", self, "_on_IdleTween_all_completed")
	_start()

func _start() -> void:
	var duration: = 1.0
	_tween_position(duration)
	_tween_rotation(duration)
	IdleTween.start()

func _tween_position(duration: float) -> void:
	var from: = 0.0
	var to: = -rand_range(8.0, 16.0)
	var trans_type_start: = Tween.TRANS_CUBIC
	var trans_type_end: = Tween.TRANS_CUBIC
	var ease_type_start: = Tween.EASE_IN_OUT
	var ease_type_end: = Tween.EASE_IN_OUT
	IdleTween.interpolate_property(self, "position:y", from, to, duration, trans_type_start, ease_type_start)
	IdleTween.interpolate_property(self, "position:y", to, from, duration, trans_type_end, ease_type_end, duration)

func _tween_rotation(duration: float) -> void:
	var from: = 0.0 - (PI/2.0)
	var to: = from + deg2rad(rand_range(-15.0, -30.0)) * Math.rand_sign()
	var trans_type_start: = Tween.TRANS_CUBIC
	var trans_type_end: = Tween.TRANS_CUBIC
	var ease_type_start: = Tween.EASE_IN_OUT
	var ease_type_end: = Tween.EASE_IN_OUT
	IdleTween.interpolate_property(self, "rotation", from, to, duration, trans_type_start, ease_type_start)
	IdleTween.interpolate_property(self, "rotation", to, from, duration, trans_type_end, ease_type_end, duration)

func _on_IdleTween_all_completed() -> void:
	_start()
