extends Node2D

var parent: Node
var target: Vector2

var mat: ShaderMaterial
var origin: = Position2D.new()
var size: = 0.0
var vertices: = 64
var duration: = 1.0

onready var tween: Tween = $Tween
onready var viewport_size: = get_viewport_rect().size
onready var aspect: = viewport_size.aspect()

func _ready() -> void:
	parent.add_child(origin)
	tween.connect("tween_all_completed", self, "_on_tween_all_completed")
	
	var canvas: = $ColorRect
	mat = canvas.get_material()
	mat.set_shader_param("vertices", vertices)
	origin.set_global_position(target)
	
	var size_end: = 0.5
	var trans: = Tween.TRANS_LINEAR
	var out: = Tween.EASE_OUT
	
	# modulate interferes with screen space shader
	tween.interpolate_property(mat, "shader_param/size", 0.0, size_end, duration, trans, out)
	tween.interpolate_property(mat, "shader_param/alpha", 2.0, 0.0, duration, trans, out)
	tween.start()

func _process(_delta: float) -> void:
	var pos: = origin.get_global_transform_with_canvas().origin
	pos /= viewport_size
	pos.x = (pos.x - 0.5) * aspect + 0.5
	pos.y = 1.0 - pos.y
	mat.set_shader_param("pos", pos)
	
	if get_tree().paused:
		tween.stop_all()
	else:
		tween.resume_all()

func _on_tween_all_completed() -> void:
	origin.queue_free() # not child of self
	queue_free()
