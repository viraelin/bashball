extends Particles2D

var time: = 0.0
var duration: float

func _ready() -> void:
	set_as_toplevel(true)
	restart()
	duration = lifetime + (lifetime * explosiveness)

func _physics_process(delta: float) -> void:
	time += delta
	if time > duration:
		queue_free()
