tool
extends Control

enum Symbol {
	None,
	Up,
	Down,
	Left,
	Right,
	Start,
	Select,
}

export(String) var text: = "" setget set_text
export(bool) var rounded: = false setget set_rounded
export(bool) var wide: = false setget set_wide
export(Symbol) var symbol: = Symbol.None setget set_symbol
export(bool) var small_font: = false setget set_small_font

var _font: DynamicFont
var _symbol_texture: StreamTexture

func _ready() -> void:
	if !Engine.editor_hint:
		_set_text()
		_set_rounded()
		_set_wide()
		_set_symbol()
		_set_small_font()

func set_text(value: String) -> void:
	text = value
	if Engine.editor_hint:
		_set_text()

func _set_text() -> void:
	$N/L.text = text

func set_rounded(value: bool) -> void:
	rounded = value
	if Engine.editor_hint:
		_set_rounded()

func _set_rounded() -> void:
	var texture: StreamTexture
	if rounded:
		texture = preload("res://res/ui-round.png")
	else:
		texture = preload("res://res/ui-flat.png")
	$N.texture = texture

func set_wide(value: bool) -> void:
	wide = value
	if Engine.editor_hint:
		_set_wide()

func _set_wide() -> void:
	var min_x: = 48
	var min_y: = min_x
	if wide:
		min_x = 128
	rect_min_size = Vector2(min_x, min_y)

func set_small_font(value: bool) -> void:
	small_font = value
	if Engine.editor_hint:
		_set_small_font()

func _set_small_font() -> void:
	var font: DynamicFont
	if small_font:
		font = preload("res://src/UI/res/buttons-font-small.tres")
	else:
		font = preload("res://src/UI/res/buttons-font.tres")
	$N/L.add_font_override("font", font)

func set_symbol(value: int) -> void:
	symbol = value
	if Engine.editor_hint:
		_set_symbol()

func _set_symbol() -> void:
	var texture: AtlasTexture
	match symbol:
		Symbol.None: texture = null
		Symbol.Up: texture = preload("res://src/UI/res/up.tres")
		Symbol.Down: texture = preload("res://src/UI/res/down.tres")
		Symbol.Left: texture = preload("res://src/UI/res/left.tres")
		Symbol.Right: texture = preload("res://src/UI/res/right.tres")
		Symbol.Start: texture = preload("res://src/UI/res/start.tres")
		Symbol.Select: texture = preload("res://src/UI/res/select.tres")
	if texture:
		$N/S.texture = texture
		$N/S.show()
		$N/L.hide()
	else:
		$N/S.hide()
		$N/L.show()
