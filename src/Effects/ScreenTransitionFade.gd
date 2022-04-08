extends "ScreenTransition.gd"

const _from: = Color.black
const _to: = _from
const _property: = "color"
const _trans_type: = Tween.TRANS_CUBIC

func _ready() -> void:
	_from.a = 0.0

func start() -> void:
	_TweenStart.interpolate_property(self, _property,
		_from, _to, duration, _trans_type)
	_TweenStart.start()

func end() -> void:
	_TweenEnd.interpolate_property(self, _property,
		_to, _from, duration, _trans_type)
	_TweenEnd.start()
