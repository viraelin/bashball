extends "ScreenTransition.gd"

const _from: = 0.0001
const _to: = 0.05
const _property: = "shader_param/pixel"
const _trans_type: = Tween.TRANS_BOUNCE

func start() -> void:
	_TweenStart.interpolate_property(material, _property,
		_from, _to, duration, _trans_type)
	_TweenStart.start()

func end() -> void:
	_TweenEnd.interpolate_property(material, _property,
		_to, _from, duration, _trans_type)
	_TweenEnd.start()
