extends "MenuButtonBase.gd"

var is_invisible: = false

export(String) var text: String

onready var _Label: Label = $Anchor/Label

func _ready() -> void:
	set_text(text)
	_set_colors()

func set_text(string: String) -> void:
	text = string
	_Label.set_text(string)

func _set_colors() -> void:
	if is_invisible:
		_Label.set_modulate(Color.transparent)
		return
		
	var color_label: Color
	
	if is_focused:
		if is_disabled:
			color_label = _color_disabled_selected
		else:
			color_label = _color_selected
	else:
		if is_disabled:
			color_label = _color_disabled
		else:
			color_label = _color_default
		
	_Label.set_modulate(color_label)
