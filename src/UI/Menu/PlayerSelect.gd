extends "Menu.gd"

var is_enabled: = false
var team: int
var shape: int

onready var id: = get_index()
onready var ReadyTween: Tween = $ReadyTween
onready var Box: Control = $Box
onready var PressButton: Control = $Box/PressButtons/Button
onready var Background: ColorRect = $Background
onready var ReadyParticles: Particles2D = $ReadyParticles
onready var parent_menu: = find_parent("MenuPlay")
onready var _press_buttons: = [PressButton, $Box/PressButtons/Key0, $Box/PressButtons/Key1]
onready var BodyControl: Control = $Box/Body
onready var Body: Node2D = $Box/Body/Body
onready var Origin: Node2D = $Box/Body/Body/Origin

func _ready() -> void:
	set_device(id)
	
	team = id
	shape = 0
	
	$Box/Name.text = "Player %s" % (id + 1)
	Background.color.a = 0.4
	
	var button_team: Control = $Box/Buttons/Team
	button_team.set_device(id)
	button_team.set_value(team)
	button_team.connect("value_changed", self, "_on_Team_value_changed")
	
	var button_shape: Control = $Box/Buttons/Shape
	button_shape.set_device(id)
	button_shape.set_value(shape)
	button_shape.connect("value_changed", self, "_on_Shape_value_changed")
	
	var body_center: = BodyControl.rect_size / 2.0
	Body.position = body_center
	
	ReadyParticles.set_as_toplevel(true)
	_setup_buttons()
	disable()
	Game.connect("last_input_type_changed", self, "_on_last_input_type_changed")

# hack
func _on_gui_input(event: InputEvent) -> void:
	input(event)

func _input(event: InputEvent) -> void:
	# hack
	if id != 0:
		input(event)

func input(event: InputEvent) -> void:
	if event.is_action_pressed(_menu_accept):
		if !is_enabled:
			enable_buttons()
			Game._last_input_type_workaround(id, event)
			accept_event()
	elif event.is_action_pressed(_menu_cancel):
		if is_enabled:
			disable_buttons()
			Game._last_input_type_workaround(id, event)
			accept_event()
	if is_enabled:
		_handle_input(event)

func enable(_index: = 0) -> void:
	set_process_input(true)
	show()
	
	for button in _press_buttons:
		button.hide()
	PressButton.show()
	Buttons.hide()
	ReadyParticles.show()
	BodyControl.hide()

func disable() -> void:
	set_process_input(false)
	hide()
	
	reset_background()
	disable_buttons()
	ReadyParticles.hide()
	ReadyParticles.restart()
	ReadyParticles.emitting = false

func enable_buttons() -> void:
	is_enabled = true
	Buttons.show()
	PressButton.hide()
	BodyControl.show()
	
	var team_button: Control = buttons[0]
	_on_Team_value_changed(team_button.value)
	
	# hack
	if id != 0:
		set_current_focus(buttons[0])
	assert(visible)
	Audio.play_system_sound("MenuConfirm")
	parent_menu.check_ready(false)

func disable_buttons() -> void:
	is_enabled = false
	Buttons.hide()
	for button in _press_buttons:
		button.hide()
	PressButton.show()
	BodyControl.hide()
	reset_background()
	set_current_focus(null)
	_last_focus = null
	if visible:
		Audio.play_system_sound("MenuBack")
	if is_instance_valid(parent_menu.PlayerSelects):
		parent_menu.check_ready(false)

func _go_back() -> void:
	return

func reset_background() -> void:
	var color: = Color.white
	color.a = 0.4
	Background.color = color

func _on_Team_value_changed(value: int) -> void:
	team = value
	var color: Color = Game.colors[value]
	Background.color = color
	Body.get_node("Outline").default_color = color
	Origin.get_node("Pointer").default_color = color
	parent_menu.check_ready(false)

func _on_Shape_value_changed(value: int) -> void:
	shape = value
	var color: Color = Game.colors[team]
	Game.set_shape(Body, Origin, value)
	Body.get_node("Outline").default_color = color
	Origin.get_node("Pointer").default_color = color

func _on_last_input_type_changed(_id: int, type: int) -> void:
	if id in [0, 1]:
		var new_press_button: Control
		if type == InputType.Controller:
			new_press_button = _press_buttons[0]
		elif type == InputType.Keyboard:
			if id == 0:
				new_press_button = _press_buttons[1]
			elif id == 1:
				new_press_button = _press_buttons[2]
				
		if PressButton.visible:
			PressButton.hide()
			new_press_button.show()
		PressButton = new_press_button
