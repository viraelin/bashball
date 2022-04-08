extends "Menu.gd"

onready var parent: Control = get_parent()

func _ready() -> void:
	show()
	disable()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_menu_cancel):
		_go_back()

func _go_back() -> void:
	disable()
	var index: int = parent.Buttons.get_node("Controls").get_index()
	parent.enable(index)
	._go_back()

func enable(index: = 0) -> void:
	$Controller.show()
	$Keyboard.show()
	.enable(index)

func disable() -> void:
	$Controller.hide()
	$Keyboard.hide()
	.disable()
