extends "Menu.gd"

onready var MenuOptions: Control = $MenuOptions
onready var Resume: Control = $Buttons/Resume
onready var Options: Control = $Buttons/Options
onready var Quit: Control = $Buttons/Quit

func _ready() -> void:
	Resume.connect("pressed", self, "_on_Resume_pressed")
	Options.connect("pressed", self, "_on_Options_pressed")
	Quit.connect("pressed", self, "_on_Quit_pressed")
	
	Buttons.hide()
	hide()
	_setup_buttons()

func _input(event: InputEvent) -> void:
	if Buttons.is_visible():
		if event.is_action_pressed(_menu_pause) || event.is_action_pressed(_menu_cancel):
			_resume()
			var id: = _device_id
			if _device_id == -1:
				id = 0
			Game._last_input_type_workaround(id, event)
			accept_event()
		else:
			_handle_input(event)
	else:
		if ! get_tree().paused && Game.can_open_pause_menu:
			if event.is_action_pressed(_menu_pause):
				_pause()
				var id: = _device_id
				if _device_id == -1:
					id = 0
				Game._last_input_type_workaround(id, event)
				accept_event()

func _go_back() -> void:
	return

func enable(index: = 0) -> void:
	.enable(index)

func disable() -> void:
	.disable()

func _pause() -> void:
	get_tree().set_pause(true)
	_last_focus = null
	show()
	Buttons.show()
	_Label.show()
	VisualServer.set_shader_time_scale(0.0)
	set_current_focus(Resume)

func _resume() -> void:
	get_tree().paused = false
	_last_focus = null
	hide()
	Buttons.hide()
	_Label.hide()
	VisualServer.set_shader_time_scale(1)

func _on_Resume_pressed() -> void:
	_resume()

func _on_Options_pressed() -> void:
	disable()
	MenuOptions.enable()

func _on_Quit_pressed() -> void:
	set_process_input(false)
	set_current_focus(null)
	_last_focus = null
	Game.emit_signal("quit_to_main_menu")
