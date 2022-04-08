extends "Menu.gd"

onready var MenuPlay: Control = $MenuPlay
onready var MenuOptions: Control = $MenuOptions
onready var MenuControls: Control = $MenuControls
onready var Title: Sprite = $Title

func _ready() -> void:
	show()
	can_wrap = false
	
	if OS.get_name() == "HTML5":
		var exit: = $Buttons/Exit
		Buttons.remove_child(exit)
		exit.queue_free()
	else:
		$Buttons/Exit.connect("pressed", self, "_on_Exit_pressed")
		
	$Buttons/Play.connect("pressed", self, "_on_Play_pressed")
	$Buttons/Options.connect("pressed", self, "_on_Options_pressed")
	$Buttons/Controls.connect("pressed", self, "_on_Controls_pressed")
	
	get_tree().paused = false
	set_current_focus(Buttons.get_child(0))
	_setup_buttons()

func _input(event: InputEvent) -> void:
	_handle_input(event)

func _go_back() -> void:
	return

func enable(index: = 0) -> void:
	Title.show()
	.enable(index)

func disable() -> void:
	Title.hide()
	.disable()

func _on_Play_pressed() -> void:
	disable()
	MenuPlay.enable()

func _on_Options_pressed() -> void:
	disable()
	MenuOptions.enable()

func _on_Controls_pressed() -> void:
	disable()
	MenuControls.enable()

func _on_Exit_pressed() -> void:
	get_tree().quit(0)
