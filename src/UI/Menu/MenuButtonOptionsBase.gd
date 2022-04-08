extends "MenuButtonBase.gd"

# warning-ignore:unused_signal
signal value_changed

export(String) var text: String

onready var _Label: Label = $Anchor/Labels/Label
onready var _ValueLabel: Label = $Anchor/Labels/Value/Label
onready var _ValueLeft: Label = $Anchor/Labels/Value/Left
onready var _ValueRight: Label = $Anchor/Labels/Value/Right

func _ready() -> void:
	set_text(text)
	_set_colors()

func set_text(string: String) -> void:
	text = string
	_Label.set_text(string)
