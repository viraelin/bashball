extends Line2D

export(int) var limit: = 16
export(float) var duration: = 0.4

var target: Node2D
var is_active: = false
var is_copy: = false

onready var DurationTimer: Timer = $DurationTimer

func _ready() -> void:
	DurationTimer.wait_time = duration
	target = get_parent()
	set_as_toplevel(true)
	set_physics_process(false)
	DurationTimer.connect("timeout", self, "_on_DurationTimer_timeout")

func _physics_process(_delta: float) -> void:
	if points.size() > limit:
		remove_point(0)
		
	if target:
		add_point(target.global_position)
		
	if ! is_active:
		if points.size() > 0:
			remove_point(0)
		if points.size() > 0:
			remove_point(0)
		else:
			disable()

func start() -> void:
	is_active = true
	set_physics_process(true)
	DurationTimer.start()

func stop() -> void:
	is_active = false

func disable() -> void:
	set_physics_process(false)
	if is_copy:
		queue_free()

func _on_DurationTimer_timeout() -> void:
	stop()
