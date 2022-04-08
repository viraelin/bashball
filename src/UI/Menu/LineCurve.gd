tool
extends Line2D

var _time: = 0.0
var _time_threshold: = 0.5

func _ready() -> void:
	if Engine.editor_hint:
		set_physics_process(true)
	else:
		set_physics_process(false)
	bake()

func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		_time += delta
		if _time > _time_threshold:
			bake()
			_time = 0.0
	else:
		set_physics_process(false)

func bake() -> void:
	var path: Path2D = get_parent()
	var curve: = path.curve
	var stages: = 5
	var degrees: = deg2rad(4.0)
	var array: = curve.tessellate(stages, degrees)
	points = array
