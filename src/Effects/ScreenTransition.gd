extends ColorRect

signal mid
signal end

const _DURATION: = 0.5
const _DURATION_FACTOR: = 0.5

var duration: = _DURATION

onready var _TweenStart: Tween = $TweenStart
onready var _TweenEnd: Tween = $TweenEnd

func _ready() -> void:
	# call 'start()' and 'end()' externally when desired and yield for signals
	_TweenStart.connect("tween_all_completed", self, "_on_TweenStart_all_completed")
	_TweenEnd.connect("tween_all_completed", self, "_on_TweenEnd_all_completed")

# virtual
func start() -> void:
	return

# virtual
func end() -> void:
	return

func _on_TweenStart_all_completed() -> void:
	var delay: = duration * _DURATION_FACTOR
	yield(get_tree().create_timer(delay), "timeout")
	emit_signal("mid")

func _on_TweenEnd_all_completed() -> void:
	emit_signal("end")
	queue_free()
