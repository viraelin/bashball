extends Node

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if event is InputEventJoypadButton || event is InputEventJoypadMotion:
			var device: = -1
			if event.device in [0, 1]:
				device = event.device
			if device != -1:
				Game.set_last_input_type(device, InputType.Controller)
		elif event is InputEventKey:
			Game.set_last_input_type(0, InputType.Keyboard)
