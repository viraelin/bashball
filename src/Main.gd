extends Node2D

var _title_screen: Node
var _world: Node

onready var PauseTimer: Timer = $PauseTimer
onready var TitleScreenScene: = preload("res://src/UI/Menu/TitleScreen.tscn")

func _ready() -> void:
	Game.connect("start_game", self, "_on_start_game")
	Game.connect("quit_to_main_menu", self, "_on_quit_to_main_menu")
	Game.connect("timed_pause", self, "_on_timed_pause")
	PauseTimer.connect("timeout", self, "_on_PauseTimer_timeout")
	
	var transition_fade: = Effects.screen_transition_fade()
	var transition_pixel: = Effects.screen_transition_pixel()
	transition_fade.duration = 1.0
	transition_pixel.duration = 1.0
	transition_fade.end()
	transition_pixel.end()
	_title_screen = TitleScreenScene.instance()
	add_child(_title_screen)

func _on_start_game(teams: Dictionary) -> void:
	var world: = preload("res://src/World.tscn")
	_world = world.instance()
	
	var transition_fade: = Effects.screen_transition_fade()
	var transition_pixel: = Effects.screen_transition_pixel()
	transition_fade.duration = 0.5
	transition_pixel.duration = 0.5
	transition_fade.start()
	transition_pixel.start()
	yield(transition_fade, "mid")
	
	if is_instance_valid(_title_screen):
		remove_child(_title_screen)
		_title_screen.queue_free()
		_title_screen = null
		
	add_child(_world)
	_world.setup_arena(teams)
	transition_fade.end()
	transition_pixel.end()
	yield(transition_fade, "end")
	_world.countdown()

func _on_quit_to_main_menu() -> void:
	assert(is_instance_valid(_world))
	assert(_title_screen == null)
	
	var transition_fade: = Effects.screen_transition_fade()
	var transition_pixel: = Effects.screen_transition_pixel()
	transition_fade.duration = 0.5
	transition_pixel.duration = 0.5
	transition_fade.start()
	transition_pixel.start()
	yield(transition_fade, "mid")
	
	# todo
	Game.players.clear()
	Game.goals.clear()
	Game.ball = null
	Game.can_open_pause_menu = false
	Game.score = [0, 0, 0, 0]
	Game.ball_contact_history.clear()
	Game.current_camera = null
	
	get_tree().set_pause(false)
	remove_child(_world)
	_world.queue_free()
	_world = null
	_title_screen = TitleScreenScene.instance()
	add_child(_title_screen)
	transition_fade.end()
	transition_pixel.end()

func _on_timed_pause(duration: = 0.1) -> void:
	get_tree().set_pause(true)
	PauseTimer.start(duration)

func _on_PauseTimer_timeout() -> void:
	get_tree().set_pause(false)
