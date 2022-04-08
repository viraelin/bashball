extends Node

# set by parent
var event: InputEvent
var button_index: int
var input_handler: FuncRef

var timer: = 0.0
var initial_repeat_timer: = 0.0

# parent expected to extend 'Menu.gd'
onready var parent: Control = get_parent()

func _physics_process(delta: float) -> void:
	if initial_repeat_timer >= 0.5:
		if timer >= 0.01:
			input_handler.call_func(event, true)
			timer = 0.0
		else:
			timer += delta
	else:
		initial_repeat_timer += delta

func destroy() -> void:
	timer = 0.0
	initial_repeat_timer = 0.0
	set_physics_process(false)
	parent.remove_child(self)
	queue_free()
