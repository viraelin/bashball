extends "MenuButtonOptionsBase.gd"

export(bool) var value: = false

func _ready() -> void:
	set_value(value)

func set_value(state: bool) -> void:
	value = state
	_set_value_text()
	_set_colors()
	emit_signal("value_changed", value)

func _set_value_text() -> void:
	if value:
		_ValueLabel.set_text("ON")
	else:
		_ValueLabel.set_text("OFF")

func _set_colors() -> void:
	var color_left: Color
	var color_right: Color
	var color_label: Color
	
	if is_focused:
		color_label = _color_selected
	else:
		color_label = _color_default
		
	if value:
		color_right = _color_disabled
		if is_focused:
			color_left = _color_selected
		else:
			color_left = _color_default
	else:
		color_left = _color_disabled
		if is_focused:
			color_right = _color_selected
		else:
			color_right = _color_default
			
	_Label.set_modulate(color_label)
	_ValueLabel.set_modulate(color_label)
	_ValueLeft.set_modulate(color_left)
	_ValueRight.set_modulate(color_right)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(_menu_accept):
		set_value(!value)
		_bounce()
		_set_colors()
		Audio.play_system_sound("MenuOptionsValueChange")
	elif event.is_action_pressed(_menu_left):
		if value:
			set_value(false)
			_bounce()
			_set_colors()
			Audio.play_system_sound("MenuOptionsValueChange")
	elif event.is_action_pressed(_menu_right):
		if !value:
			set_value(true)
			_bounce()
			_set_colors()
			Audio.play_system_sound("MenuOptionsValueChange")
