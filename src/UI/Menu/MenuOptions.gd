extends "Menu.gd"

const SECTION_OPTIONS: = "options"

var keys: = [
	"Labels",
	"P1KeyboardSpeed",
	"P2KeyboardSpeed",
	"Fullscreen",
	"VSync",
	"ScreenShake",
	"SFXVolume",
]

onready var parent: Control = get_parent()

func _ready() -> void:
	show()
	$Buttons/Labels.connect("value_changed", self, "_on_Labels_value_changed")
	$Buttons/P1KeyboardSpeed.connect("value_changed", self, "_on_P1KeyboardSpeed_value_changed")
	$Buttons/P2KeyboardSpeed.connect("value_changed", self, "_on_P2KeyboardSpeed_value_changed")
	$Buttons/Fullscreen.connect("value_changed", self, "_on_Fullscreen_value_changed")
	$Buttons/VSync.connect("value_changed", self, "_on_VSync_value_changed")
	$Buttons/ScreenShake.connect("value_changed", self, "_on_ScreenShake_value_changed")
	$Buttons/SFXVolume.connect("value_changed", self, "_on_SFXVolume_value_changed")
	
	_load_conf()
	disable()
	_setup_buttons()

func _input(event: InputEvent) -> void:
	_handle_input(event)

func _go_back() -> void:
	disable()
	var index: int = parent.Buttons.get_node("Options").get_index()
	parent.enable(index)
	_save_conf()
	._go_back()

func enable(index: = 0) -> void:
	.enable(index)

func disable() -> void:
	.disable()

func _load_conf() -> void:
	for key in keys:
		_load_key(key)
	_save_conf()

func _save_conf() -> void:
	for key in keys:
		_save_key(key)
	Game.save_conf()

func _load_key(key: String) -> void:
	var node: = Buttons.get_node(key)
	# cannot infer type
	var value = Game.options_config.get_value(SECTION_OPTIONS, key, node.value)
	node.set_value(value)

func _save_key(key: String) -> void:
	var node: = Buttons.get_node(key)
	Game.options_config.set_value(SECTION_OPTIONS, key, node.value)

func set_volume(bus_idx: int, value: int) -> void:
	if value == 0:
		AudioServer.set_bus_mute(bus_idx, true)
	elif AudioServer.is_bus_mute(bus_idx):
		AudioServer.set_bus_mute(bus_idx, false)
		
	var volume: = value - 10
	AudioServer.set_bus_volume_db(bus_idx, volume)

func _on_Labels_value_changed(value: bool) -> void:
	Game.emit_signal("options_set_labels_state", value)

func _on_P1KeyboardSpeed_value_changed(value: int) -> void:
	Game.emit_signal("options_turn_speed_changed", 0, value - 1)

func _on_P2KeyboardSpeed_value_changed(value: int) -> void:
	Game.emit_signal("options_turn_speed_changed", 1, value - 1)

func _on_Fullscreen_value_changed(value: bool) -> void:
	OS.set_window_fullscreen(value)

func _on_VSync_value_changed(value: bool) -> void:
	OS.set_use_vsync(value)

func _on_ScreenShake_value_changed(value: bool) -> void:
	Game.emit_signal("options_set_screen_shake_state", value)

func _on_SFXVolume_value_changed(value: int) -> void:
	var bus_idx: = AudioServer.get_bus_index("SFX")
	set_volume(bus_idx, value)
