extends Control

signal pressed

var custom_index: int
var origin: Vector2
var is_disabled: = false
var _key_repeat_time: = 0.0
var _color_default: = Color("#777777")
var _color_selected: = Color("#FFFFFF")
var _color_disabled: = Color("#222222")
var _color_disabled_selected: = Color("#252525")
var _color_pulse: = Color("#DBDBDB")
var is_focused: = false

var _device_id: int
var _menu_left: String
var _menu_right: String
var _menu_up: String
var _menu_down: String
var _menu_accept: String
var _menu_cancel: String

onready var _Anchor: Control = $Anchor
onready var _anchor_start_position: = _Anchor.rect_position
onready var _FocusTween: Tween = $FocusTween
onready var _PulseTween: Tween = $PulseTween

func _ready() -> void:
	set_device(-1)

func set_device(id: int) -> void:
	# similar to 'Menu.gd'
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

func _bounce() -> void:
	var offset: = Vector2(0, 4)
	var property: = "rect_position"
	var from: = _anchor_start_position
	var to: = _anchor_start_position + offset
	var duration_start: = 0.1
	var duration_end: = 0.1
	var delay: = 0.1
	var trans_type: = Tween.TRANS_CUBIC
	var ease_type = Tween.EASE_IN_OUT
	
	_FocusTween.interpolate_property(_Anchor, property, from, to,
		duration_start, trans_type, ease_type)
	_FocusTween.interpolate_property(_Anchor, property, to, from,
		duration_end, trans_type, ease_type, delay)
	_FocusTween.start()

func _pulse() -> void:
	var from: = Color(1.0, 1.0, 1.0)
	var to: = Color(0.9, 0.9, 0.9)
	
	var duration: = 0.2
	_PulseTween.interpolate_property(_Anchor, "modulate", from, to, duration)
	_PulseTween.start()

func _on_focus_entered() -> void:
	is_focused = true
	_bounce()
	_pulse()
	_set_colors()

func _on_focus_exited() -> void:
	is_focused = false
	_PulseTween.remove_all()
	_Anchor.set_modulate(Color.white)
	_set_colors()

func _set_colors() -> void:
	return

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(_menu_accept):
		if ! is_disabled:
			emit_signal("pressed")
			_bounce()
			Audio.play_system_sound("MenuConfirm")

func set_disabled(state: bool) -> void:
	is_disabled = state
	_set_colors()
