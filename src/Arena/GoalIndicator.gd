extends Node2D

var color: Color

onready var _Tween: Tween = $Tween

func _ready() -> void:
	.hide()

func set_color(value: Color) -> void:
	color = value
	modulate = value

func show() -> void:
	var from: = color
	var to: = color
	var duration: = 0.25
	from.a = 0.0
	_Tween.interpolate_property(self, "modulate", from, to, duration, Tween.TRANS_CUBIC)
	_Tween.start()
	.show()

func hide() -> void:
	var from: = color
	var to: = color
	var duration: = 0.25
	to.a = 0.0
	_Tween.interpolate_property(self, "modulate", from, to, duration, Tween.TRANS_CUBIC)
	_Tween.start()
