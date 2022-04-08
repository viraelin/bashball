extends Control

var _key_repeat_time: = 0.0
var _last_focus: Control
var current_focus: Control
var can_wrap: = true
var buttons: = []
var _fake_event_node: Node

var _device_id: int
var _menu_left: String
var _menu_right: String
var _menu_up: String
var _menu_down: String
var _menu_accept: String
var _menu_cancel: String
var _menu_pause: String

onready var Buttons: Control = find_node("Buttons")
onready var _Label: Label = get_node_or_null("Label")
onready var NavigationButtons: Control = get_node_or_null("NavigationButtons")

func _ready() -> void:
	set_device(-1)

func set_device(id: int) -> void:
	# similar to 'MenuButtonBase.gd'
	var key: = ""
	if id != -1:
		key = "%s_" % id
		
	_device_id = id
	_menu_left = "%smenu_left" % key
	_menu_right = "%smenu_right" % key
	_menu_up = "%smenu_up" % key
	_menu_down = "%smenu_down" % key
	_menu_accept = "%smenu_accept" % key
	_menu_cancel = "%smenu_cancel" % key
	_menu_pause = "%smenu_pause" % key

func _setup_buttons() -> void:
	buttons.append_array(Buttons.get_children())

func _handle_input(event: InputEvent, is_fake: = false) -> void:
	if !is_fake:
		controller_fake_echo(event)
		
	if current_focus:
		current_focus._on_gui_input(event)
		
	if event.is_action_pressed(_menu_cancel):
		_go_back()
		return
		
	if event.is_action_released(_menu_up) || event.is_action_released(_menu_down):
		_key_repeat_time = 0.0
		return
		
	var indices: = []
	var index: = 0
	for button in buttons:
#		if button.is_visible():
#			indices.append(index)
		indices.append(index)
		button.custom_index = index
		index += 1
		
	if event.is_action(_menu_up):
		_key_repeat_time += Game.UI_KEY_REPEAT_TIME_INCREMENT
		if _key_repeat_time >= Game.UI_KEY_REPEAT_DELAY:
			_navigate_up(indices, false)
			_key_repeat_time = Game.UI_KEY_REPEAT_RATE
			return
	elif event.is_action(_menu_down):
		_key_repeat_time += Game.UI_KEY_REPEAT_TIME_INCREMENT
		if _key_repeat_time >= Game.UI_KEY_REPEAT_DELAY:
			_navigate_down(indices, false)
			_key_repeat_time = Game.UI_KEY_REPEAT_RATE
			return
			
	if event.is_action_pressed(_menu_up):
		_navigate_up(indices, can_wrap)
		return
	elif event.is_action_pressed(_menu_down):
		_navigate_down(indices, can_wrap)
		return

func _navigate_up(indices: Array, can_wrap_local: bool) -> void:
	assert(current_focus)
	var index_focus: int = current_focus.custom_index
	var index_next: = indices.find(index_focus) - 1
	var idx: int
	
	if index_next < 0:
		if can_wrap_local:
			idx = indices[-1]
		else:
			idx = indices[0]
	else:
		idx = indices[index_next]
		
	_select_button(idx)

func _navigate_down(indices: Array, can_wrap_local: bool) -> void:
	assert(current_focus)
	var index_focus: int = current_focus.custom_index
	var index_next: = indices.find(index_focus) + 1
	var idx: int
	
	if index_next > indices.size() - 1:
		if can_wrap_local:
			idx = indices[0]
		else:
			idx = indices[-1]
	else:
		idx = indices[index_next]
		
	_select_button(idx)

func _select_button(idx: int) -> void:
	var button: Control = buttons[idx]
	if _last_focus != button && current_focus != button:
		set_current_focus(button)
		_last_focus = button
		Audio.play_system_sound("MenuMove")

func _go_back() -> void:
	Audio.play_system_sound("MenuBack")

func enable(index: = 0) -> void:
	_last_focus = null
	set_process_input(true)
	Buttons.show()
	
	if NavigationButtons:
		NavigationButtons.show()
		
	var size: = buttons.size()
	if size > 0 && index < size:
		set_current_focus(buttons[index])
		
	if _Label:
		_Label.show()

func disable() -> void:
	if _fake_event_node:
		_fake_event_node.destroy()
		_fake_event_node = null
	set_process_input(false)
	Buttons.hide()
	
	if NavigationButtons:
		NavigationButtons.hide()
		
	if _Label:
		_Label.hide()

func set_current_focus(node: Control) -> void:
	if current_focus:
		current_focus._on_focus_exited()
		
	if node:
		current_focus = node
		current_focus._on_focus_entered()

func controller_fake_echo(event: InputEvent) -> void:
	# hack: controller echo event workaround (echo is not sent normally)
	if event is InputEventJoypadButton:
		if event.is_action_pressed(_menu_up) || event.is_action_pressed(_menu_down):
			if !_fake_event_node:
				var fake_event: = InputEventKey.new()
				fake_event.pressed = true
				fake_event.echo = true
				if event.is_action_pressed(_menu_up):
					fake_event.scancode = KEY_UP
				elif event.is_action_pressed(_menu_down):
					fake_event.scancode = KEY_DOWN
					
				_fake_event_node = preload("res://src/UI/Menu/ControllerFakeEcho.tscn").instance()
				_fake_event_node.input_handler = funcref(self, "_handle_input")
				_fake_event_node.button_index = event.button_index
				_fake_event_node.event = fake_event
				add_child(_fake_event_node)
		else:
			if _fake_event_node && _fake_event_node.button_index == event.button_index:
				_fake_event_node.destroy()
				_fake_event_node = null
