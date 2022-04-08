extends "MenuButtonOptionsBase.gd"

export(int) var value: = 0
export(int) var value_min: = 0
export(int) var value_max: = 10
export(Array, String) var aliases: = []

func _ready() -> void:
	set_value(value)

func set_value(input: int) -> void:
	value = input
	value = int(clamp(value, value_min, value_max))
	_set_value_text()
	_set_colors()
	emit_signal("value_changed", value)

func gui_change_value(input: int) -> void:
	if input >= value_min && input <= value_max:
		set_value(input)
		_bounce()
		_set_colors()
		Audio.play_system_sound("MenuOptionsValueChange")

func _set_value_text() -> void:
	if aliases.size() > 0:
		var alias: String = aliases[value]
		_ValueLabel.set_text(alias)
	else:
		_ValueLabel.set_text(str(value))

func _set_colors() -> void:
	var color_left: Color
	var color_right: Color
	var color_label: Color
	
	if is_focused:
		color_label = _color_selected
	else:
		color_label = _color_default
	
	if value <= value_min:
		color_left = _color_disabled
		if is_focused:
			color_right = _color_selected
		else:
			color_right = _color_default
	elif value >= value_max:
		color_right = _color_disabled
		if is_focused:
			color_left = _color_selected
		else:
			color_left = _color_default
	else:
		if is_focused:
			color_left = _color_selected
			color_right = _color_selected
		else:
			color_left = _color_default
			color_right = _color_default
			
	_Label.set_modulate(color_label)
	_ValueLabel.set_modulate(color_label)
	_ValueLeft.set_modulate(color_left)
	_ValueRight.set_modulate(color_right)

func _on_gui_input(event: InputEvent, is_fake: = false) -> void:
	if !is_fake:
		controller_fake_echo(event)
		
	if event.is_action_released(_menu_left) || event.is_action_released(_menu_right):
		_key_repeat_time = 0.0
		return
		
	if event.is_action(_menu_left):
		_key_repeat_time += Game.UI_KEY_REPEAT_TIME_INCREMENT
		if _key_repeat_time >= Game.UI_KEY_REPEAT_DELAY:
			gui_change_value(value - 1)
			_key_repeat_time = Game.UI_KEY_REPEAT_RATE
			return
	elif event.is_action(_menu_right):
		_key_repeat_time += Game.UI_KEY_REPEAT_TIME_INCREMENT
		if _key_repeat_time >= Game.UI_KEY_REPEAT_DELAY:
			gui_change_value(value + 1)
			_key_repeat_time = Game.UI_KEY_REPEAT_RATE
			return
			
	if event.is_action_pressed(_menu_left):
		gui_change_value(value - 1)
	elif event.is_action_pressed(_menu_right):
		gui_change_value(value + 1)

var _fake_event_node: Node
func controller_fake_echo(event: InputEvent) -> void:
	# hack: controller echo event workaround (echo is not sent normally)
	if event is InputEventJoypadButton:
		if event.is_action_pressed(_menu_left) || event.is_action_pressed(_menu_right):
			if !_fake_event_node:
				var fake_event: = InputEventKey.new()
				fake_event.pressed = true
				fake_event.echo = true
				
				if event.is_action_pressed(_menu_left):
					fake_event.scancode = KEY_LEFT
				elif event.is_action_pressed(_menu_right):
					fake_event.scancode = KEY_RIGHT
					
				_fake_event_node = preload("res://src/UI/Menu/ControllerFakeEcho.tscn").instance()
				_fake_event_node.input_handler = funcref(self, "_on_gui_input")
				_fake_event_node.button_index = event.button_index
				_fake_event_node.event = fake_event
				add_child(_fake_event_node)
		else:
			if _fake_event_node && _fake_event_node.button_index == event.button_index:
				_fake_event_node.destroy()
				_fake_event_node = null

func _on_focus_exited() -> void:
	._on_focus_exited()
	if _fake_event_node:
		_fake_event_node.destroy()
		remove_child(_fake_event_node)
		_fake_event_node.queue_free()
		_fake_event_node = null
