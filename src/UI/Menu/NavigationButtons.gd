extends Control

func _ready() -> void:
	Game.connect("last_input_type_changed", self, "_on_last_input_type_changed")

func _on_last_input_type_changed(id: int, type: int) -> void:
	if id == 0:
		if type == InputType.Controller:
			$H/Back/Key.hide()
			$H/Back/Button.show()
		elif type == InputType.Keyboard:
			$H/Back/Key.show()
			$H/Back/Button.hide()
