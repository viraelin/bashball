extends Node

# warning-ignore-all:unused_signal
signal start_game(teams)
signal goal_scored(goal)
signal screen_shake(duration, strength)
signal options_set_screen_shake_state(state)
signal quit_to_main_menu
signal timed_pause(duration)
signal options_set_labels_state(state)
signal rematch
signal update_score_ui(team)
signal score_reset
signal options_turn_speed_changed(id, value)
signal goal_entered_screen(goal)
signal goal_exited_screen(goal)
signal last_input_type_changed(id, type)

var colors: = {
	0: Color("17a8ff"),
	1: Color("e83b29"),
	2: Color("28b94c"),
	3: Color("c3d640"),
}

var team_names: = {
	0: "Team 1",
	1: "Team 2",
	2: "Team 3",
	3: "Team 4",
}

const UI_KEY_REPEAT_DELAY: = 0.25
const UI_KEY_REPEAT_RATE: = UI_KEY_REPEAT_DELAY - 0.12
const UI_KEY_REPEAT_TIME_INCREMENT: = 0.1

var options_config_file_path: = "user://config.ini"
var options_config: = ConfigFile.new()

var score: = [0, 0, 0, 0]
var goals: = []
var players: = []
var ball: Ball
var can_open_pause_menu: = false
var ball_contact_history: = []
var current_camera: Camera2D

var _action_names: = [
	"left", "right", "up", "down", "boost",
	"menu_up", "menu_down", "menu_left", "menu_right",
	"menu_accept", "menu_cancel", "menu_pause",
]

var _last_input_type: = {
	0: InputType.Controller,
	1: InputType.Controller,
}

#var active_controllers: = []

func _init() -> void:
	load_config()

func _ready() -> void:
#	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	add_device_actions(0)
	add_device_actions(1)
	add_device_actions(2)
	add_device_actions(3)

func add_device_actions(id: int) -> void:
#	if id in active_controllers:
#		return
		
#	active_controllers.append(id)
	
	# todo: support for left/right separation of modifier keys
	for action_name in _action_names:
		var new_action_name: = "%s_%s" % [id, action_name]
		InputMap.add_action(new_action_name)
		
		if id == 0:
			var new_key_event: = InputEventKey.new()
			new_key_event.device = 0
			match action_name:
				"left": new_key_event.scancode = KEY_LEFT
				"right": new_key_event.scancode = KEY_RIGHT
				"up": new_key_event.scancode = KEY_UP
				"down": new_key_event.scancode = KEY_DOWN
				"boost": new_key_event.scancode = KEY_CONTROL
			if new_key_event.scancode:
				if !action_name.begins_with("menu"):
					var new_key_action_name: = "%s_kb" % new_action_name
					InputMap.add_action(new_key_action_name)
					InputMap.action_add_event(new_key_action_name, new_key_event)
				else:
					InputMap.action_add_event(new_action_name, new_key_event)
		elif id == 1:
			var new_key_event: = InputEventKey.new()
			new_key_event.device = 0
			match action_name:
				"left": new_key_event.scancode = KEY_A
				"right": new_key_event.scancode = KEY_D
				"up": new_key_event.scancode = KEY_W
				"down": new_key_event.scancode = KEY_S
				"boost": new_key_event.scancode = KEY_SHIFT
				"menu_accept": new_key_event.scancode = KEY_E
				"menu_cancel": new_key_event.scancode = KEY_Q
				"menu_left": new_key_event.scancode = KEY_A
				"menu_right": new_key_event.scancode = KEY_D
				"menu_up": new_key_event.scancode = KEY_W
				"menu_down": new_key_event.scancode = KEY_S
				
			if new_key_event.scancode:
				if !action_name.begins_with("menu"):
					var new_key_action_name: = "%s_kb" % new_action_name
					InputMap.add_action(new_key_action_name)
					InputMap.action_add_event(new_key_action_name, new_key_event)
				else:
					InputMap.action_add_event(new_action_name, new_key_event)
				
		var action_list: = InputMap.get_action_list(action_name)
		for event in action_list:
			var new_event: InputEvent = event.duplicate(true)
			new_event.device = id
			InputMap.action_add_event(new_action_name, new_event)

#func remove_controller_actions(id: int) -> void:
#	if ! id in active_controllers:
#		return
#
#	active_controllers.erase(id)
#	for action_name in _action_names:
#		var new_action_name: = "%s_%s" % [id, action_name]
#		InputMap.erase_action(new_action_name)

#func _on_joy_connection_changed(device: int, connected: bool) -> void:
#	if connected:
#		add_device_actions(device)
#	else:
#		remove_controller_actions(device)

func report_ball_contact(team: int) -> void:
	var ball_contact_history_limit: = 128
	if ball_contact_history.size() > 0:
		if ball_contact_history[0] != team:
			ball_contact_history.push_front(team)
	else:
		ball_contact_history.push_front(team)
		
	if ball_contact_history.size() > ball_contact_history_limit:
		ball_contact_history.pop_back()

func set_last_input_type(id: int, type: int) -> void:
	_last_input_type[id] = type
	emit_signal("last_input_type_changed", id, type)

func _last_input_type_workaround(id: int, event: InputEvent) -> void:
	# hack: because 'accept_event()' prevents propogation to updater
	if id in [0, 1]:
		var type: = -1
		if event is InputEventJoypadButton || event is InputEventJoypadMotion:
			type = InputType.Controller
		elif event is InputEventKey:
			type = InputType.Keyboard
		if type != -1:
			set_last_input_type(id, type)

func set_shape(body: Node2D, origin: Node2D, type: int) -> Dictionary:
	var body_fill: = body.get_node("Fill")
	var body_outline: = body.get_node("Outline")
	var origin_outline: = origin.get_node("Pointer")
	
	var vertices: int
	var radius: int
	var angle: int
	
	if type == 0:
		vertices = 4
		angle = 45
		radius = 32
	elif type == 1:
		vertices = 3
		angle = 60
		radius = 32
	elif type == 2:
		vertices = 64
		angle = 0
		radius = 24
		
	body_fill.set_vertices(vertices)
	body_fill.set_angle(angle)
	body_fill.set_radius(radius)
	body_outline.set_vertices(vertices)
	body_outline.set_angle(angle)
	body_outline.set_radius(radius)
	origin_outline.set_vertices(vertices)
	origin_outline.set_radius(radius / 4.0)
	origin_outline.set_angle(angle)
	
	return {
		0: vertices,
		1: angle,
		2: radius,
	}

func save_conf() -> void:
	var error: = options_config.save(options_config_file_path)
	match error:
		OK:
			pass
		_:
			push_error("unable to save configuration file")

func load_config() -> void:
	var error: = options_config.load(options_config_file_path)
	match error:
		OK:
			pass
		ERR_FILE_NOT_FOUND:
			pass
		_:
			push_error("unable to load configuration file")
