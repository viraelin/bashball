extends Tween

signal end

const PROPERTY: = "time_scale"

var from: = 1.0
var mid: = 0.5
var to: = 1.0
var duration: = 0.5
var trans_type: = Tween.TRANS_CUBIC
var ease_type: = Tween.EASE_OUT

func _ready() -> void:
	interpolate_property(Engine, PROPERTY, from, mid, duration, trans_type, ease_type)
	interpolate_property(Engine, PROPERTY, mid, to, duration, trans_type, ease_type, duration)
	start()
	yield(self, "tween_all_completed")
	emit_signal("end")
	Engine.time_scale = 1
	queue_free()
