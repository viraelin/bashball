extends Node2D

var play_mode: int
var current_teams: Dictionary

onready var HUD: Control = $HUD/HUD
onready var Clock: Label = $HUD/HUD/H/Clock
onready var ArenaRoot: Node2D = $ArenaRoot
onready var ScoreTween: Tween = $ScoreTween
onready var Menu: CanvasLayer = $Menu

func _ready() -> void:
	Clock.connect("time_up", self, "_on_Clock_time_up")
	Game.connect("goal_scored", self, "_on_goal_scored")
	Game.connect("rematch", self, "_on_rematch")

func setup_arena(teams: Dictionary) -> void:
	var arena_scene: PackedScene
	var team_count: = teams.keys().size()
	play_mode = team_count
	current_teams = teams
	
	match team_count:
		2: arena_scene = preload("res://src/Arena/Arena2T.tscn")
		3: arena_scene = preload("res://src/Arena/Arena3T.tscn")
		4: arena_scene = preload("res://src/Arena/Arena4T.tscn")
		
	assert(arena_scene)
	var arena: = _add_arena(arena_scene)
	_setup_teams(arena, teams)
	disable()

func _add_arena(scene: PackedScene) -> Node2D:
	var arena: Node2D = scene.instance()
	arena.name = "Arena"
	ArenaRoot.add_child(arena)
	return arena

func _setup_teams(arena: Node2D, teams: Dictionary) -> void:
	var players_root: = arena.get_node("Players")
	var player_scene: = preload("res://src/Player/Player.tscn")
	var player_ai_scene: = preload("res://src/Player/AI/PlayerAI.tscn")
	var team_count: = teams.keys().size()
	
	var goals: = []
	var goal_names: = []
	# setup goals and ui first
	for team_index in range(0, team_count):
		var team: int = teams.keys()[team_index]
		var goal: = arena.get_node("Goal%s" % [team_index + 1])
		var frame: = arena.get_node("Frame%s" % [team_index + 1])
		var color: Color = Game.colors[team]
		color.a = 0.2
		frame.default_color = Game.colors[team]
		goal.team = team
		goal.setup()
		goals.append(goal)
		goal_names.append(goal.name)
		
	# hack: fix name conflicts
	var name_index: = 0
	for goal in goals:
		var new_name: = "Goal%s" % [goal.team + 1]
		for other_goal in goals:
			if other_goal != goal:
				if new_name == other_goal.name:
					other_goal.name = "Temporary%s" % name_index
					name_index += 1
		name_index += 1
		goal.name = new_name
		
	for team_index in range(0, team_count):
		var team: int = teams.keys()[team_index]
		var ps: Array = teams.get(team)
		var goal: = arena.get_node("Goal%s" % [team + 1])
		var spawns: = goal.get_node("Spawns")
		for spawn_index in range(0, ps.size()):
			var player_info: PlayerInfo = ps[spawn_index]
			var device: = player_info.device
			var shape: = player_info.shape
			var is_ai: = player_info.ai
			var player: Player
			if is_ai:
				player = player_ai_scene.instance()
				if ps.size() > 1 && spawn_index == ps.size() - 1:
					player.initial_state = player.State.Defend
			else:
				player = player_scene.instance()
				
			var spawn_name: = "Spawn%s" % [spawn_index + 1]
			var spawn: Position2D = spawns.get_node(spawn_name)
			player.name = "Player%s" % device
			player.id = device
			player.team = team
			player.position = spawn.global_position
			player.rotation = spawn.global_rotation
			players_root.add_child(player)
			player.set_shape(shape)

func disable() -> void:
	Game.ball.disable()
	for player in Game.players:
		player.disable()
	for goal in Game.goals:
		goal.disable()

func countdown() -> void:
	var countdown: = Effects.countdown()
	countdown.start()
	yield(countdown, "finished")
	start_match()

func start_match() -> void:
	Game.can_open_pause_menu = true
	Clock.start_timer()
	Game.ball.enable()
	for player in Game.players:
		player.enable()
	for goal in Game.goals:
		goal.enable()

func end_game() -> void:
	var highest_score: int = Game.score.max()
	var highest_score_count: = Game.score.count(highest_score)
	var menu_victory_scene: = preload("res://src/UI/Menu/MenuVictory.tscn")
	
	if highest_score_count == 1:
		var winner: = Game.score.find(highest_score)
		var menu_victory: = menu_victory_scene.instance()
		menu_victory.winning_team = winner
		Menu.add_child(menu_victory)
		Audio.play("Winner")
	else:
		assert(!Clock.is_overtime)
		Clock.set_overtime()
		var overtime: = Effects.overtime()
		yield(overtime, "finished")
		reset_field(true)

func add_point(team: int) -> void:
	Game.score[team] += 1
	Game.emit_signal("update_score_ui", team)

func _on_goal_scored(team: int) -> void:
	var scoring_team: = -1
	
	match play_mode:
		2:
			var keys: = current_teams.keys()
			var index: = keys.find(team)
			match index:
				0: scoring_team = keys[1]
				1: scoring_team = keys[0]
		3:
			scoring_team = get_scoring_team(team)
		4:
			scoring_team = get_scoring_team(team)
			
	if scoring_team != -1:
		add_point(scoring_team)
		
	if Clock.is_overtime:
		Clock._time_up()
	else:
		var clock_at_zero: bool = Clock.check_zero()
		if clock_at_zero:
			Clock._time_up()
		else:
			reset_field(true)

func get_scoring_team(team: int) -> int:
	for t in Game.ball_contact_history:
		if team != t:
			return t
	return -1

func reset_field(is_slow: bool) -> void:
	Clock.stop_timer()
	Game.can_open_pause_menu = false
	
	for goal in Game.goals:
		goal.disable()
		
	if is_slow:
		var slow: = Effects.slow()
		yield(slow, "end")
		
	var transition: = Effects.screen_transition_pixel()
	transition.duration = 0.3
	transition.start()
	yield(transition, "mid")
	
	Game.ball.disable()
	Game.ball.reset()
	for player in Game.players:
		player.disable()
		player.reset()
	
	transition.end()
	yield(transition, "end")
	get_tree().paused = false
	
	countdown()

func _on_Clock_time_up() -> void:
	Clock.stop_timer()
	Game.can_open_pause_menu = false
	
	for goal in Game.goals:
		goal.disable()
		
	var slow: = Effects.slow()
	yield(slow, "end")
	end_game()

func _on_rematch() -> void:
	Game.score = [0, 0, 0, 0]
	Game.emit_signal("score_reset")
	Clock.reset()
	reset_field(false)
