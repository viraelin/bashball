extends Particles2D

var is_active: = false

func _ready() -> void:
	set_as_toplevel(true)

func start() -> void:
	is_active = true
	restart()
	Effects.spark_count += 1
	yield(get_tree().create_timer(lifetime), "timeout")
	is_active = false
	Effects.spark_count -= 1
