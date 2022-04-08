extends ColorRect

const _DURATION: = 0.2
const _STRENGTH: = 4.0
const _RANGE: = 1.0

var _strength: = _STRENGTH

onready var _Duration: Timer = $Duration

func _ready() -> void:
	Game.connect("options_set_screen_shake_state", self, "_on_options_set_screen_shake_state")
	set_process(false)
	_Duration.connect("timeout", self, "_on_Duration_timeout")

func _process(_delta: float) -> void:
	var x: = rand_range(-_RANGE, _RANGE) * _strength
	var y: = rand_range(-_RANGE, _RANGE) * _strength
	var z: = rand_range(-_RANGE, _RANGE) * _strength
	material.set_shader_param("xyz", Vector3(x, y, z))

func _on_screen_shake(duration: = _DURATION, strength: = _STRENGTH) -> void:
	_Duration.start(duration)
	_strength = strength
	set_process(true)

func _on_Duration_timeout() -> void:
	set_process(false)
	material.set_shader_param("xyz", Vector3())

func _on_options_set_screen_shake_state(state: bool) -> void:
	if state:
		if ! Game.is_connected("screen_shake", self, "_on_screen_shake"):
			Game.connect("screen_shake", self, "_on_screen_shake")
	else:
		if Game.is_connected("screen_shake", self, "_on_screen_shake"):
			Game.disconnect("screen_shake", self, "_on_screen_shake")
		_on_Duration_timeout()
