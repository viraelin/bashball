extends "Menu.gd"

var winning_team: int

onready var Animator: AnimationPlayer = $Animator

func _ready() -> void:
	$Buttons/Rematch.connect("pressed", self, "_on_Rematch_pressed")
	$Buttons/Exit.connect("pressed", self, "_on_Exit_pressed")
	_show_winners()
	set_current_focus(Buttons.get_child(0))
	_setup_buttons()
	get_tree().paused = true
	
	modulate.a = 0.0
	enable()

func _input(event: InputEvent) -> void:
	_handle_input(event)

func enable(index: = 0) -> void:
	Animator.playback_speed = 1.0
	Animator.play("show")
	.enable(index)

func disable() -> void:
	get_tree().paused = false
	.disable()

func _go_back() -> void:
	return

func _on_Rematch_pressed() -> void:
	set_process_input(false)
	for button in buttons:
		button.set_process_input(false)
		button.disconnect("gui_input", button, "_on_gui_input")
		
	Animator.playback_speed = 3.0
	Animator.play_backwards("show")
	Game.emit_signal("rematch")
	yield(Animator, "animation_finished")
	queue_free()

func _on_Exit_pressed() -> void:
	set_process_input(false)
	for button in buttons:
		button.set_process_input(false)
		button.disconnect("gui_input", button, "_on_gui_input")
	Game.emit_signal("quit_to_main_menu")

func _show_winners() -> void:
	var player_victory_model_scene: = preload("res://src/UI/Menu/PlayerVictoryModel.tscn")
	var team_members: Node2D = $TeamMembers
	
	var players: = []
	
	# DEBUG
#	for i in range(0, 7):
#		var player: = preload("res://src/Player/Player.tscn").instance()
#		Game.add_child(player)
	
	for player in Game.players:
		if player.team == winning_team:
			players.append(player)
			
	var team_size: = players.size()
	var color: Color = Game.colors[winning_team]
	var particles: Particles2D = $TeamMembers/Particles2D
	particles.modulate = color
	particles.restart()
	
	var x: = 0
	var x_separation: = 80
	# warning-ignore:integer_division
	var x_separation_half: = x_separation / 2
	var flip: = 1
	
	for i in range(0, team_size):
		x += x_separation * i * flip
		flip *= -1
		
		var player: Player = players[i]
		var model: = player_victory_model_scene.instance()
		model.name = player.name
		var body: Node2D = player.Body.duplicate()
		body.position = Vector2.ZERO
		body.rotation = 0.0
		body.scale = Vector2.ONE
		var origin: Node2D = player.Origin.duplicate()
		origin.position = Vector2.ZERO
		origin.rotation = 0.0
		origin.scale = Vector2.ONE
		
		var member: = Position2D.new()
		member.name = "Member%s" % (i + 1)
		
		if team_size % 2 == 0:
			member.position.x += x_separation_half
			
		member.position.x += x
		
		team_members.add_child(member)
		member.add_child(model)
		model.add_child(body)
		body.add_child(origin)
