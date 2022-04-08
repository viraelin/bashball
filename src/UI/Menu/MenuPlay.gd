extends "Menu.gd"

var _has_started: = false
var start_modulate_alpha: = 0.25

onready var parent: Control = get_parent()
onready var PlayerSelects: Control = $PlayerSelects
onready var AIButtons: = [
	$Buttons/AI1,
	$Buttons/AI2,
	$Buttons/AI3,
	$Buttons/AI4
]
onready var StartButton: = $Buttons/Start

func _ready() -> void:
	show()
	disable()
	buttons.append(PlayerSelects.get_child(0).get_node("Box/Buttons/Team"))
	buttons.append(PlayerSelects.get_child(0).get_node("Box/Buttons/Shape"))
	_setup_buttons()
	
	StartButton.connect("pressed", self, "_on_StartButton_pressed")
	
	var ai_team_limit: = 2
	for button in AIButtons:
		var team: int = button.get_index()
		button.value_max = ai_team_limit
		button.connect("value_changed", self, "_on_AITeamButton_value_changed", [team])

func _input(event: InputEvent) -> void:
	var p1: = PlayerSelects.get_child(0)
	if event.is_action_pressed(_menu_accept):
		if current_focus in [buttons[0], buttons[1]] && !p1.is_enabled:
			p1._on_gui_input(event)
			return
	elif event.is_action_pressed(_menu_cancel):
		if current_focus in [buttons[0], buttons[1]] && p1.is_enabled:
			p1._on_gui_input(event)
			return
	_handle_input(event)

func _go_back() -> void:
	disable()
	var index: int = parent.Buttons.get_node("Play").get_index()
	parent.enable(index)
	._go_back()

func enable(index: = 0) -> void:
	.enable(index)
	StartButton.set_disabled(true)
	for player_select in PlayerSelects.get_children():
		player_select.enable()

func disable() -> void:
	.disable()
	StartButton.set_disabled(true)
	for player_select in PlayerSelects.get_children():
		player_select.disable()
	_has_started = false

func check_ready(is_real: bool) -> void:
	if _has_started:
		return
		
	var player_enabled_count: = 0
	var player_selects: = PlayerSelects.get_children()
	var teams: = {}
	
	for player_select in player_selects:
		if player_select.is_enabled:
			player_enabled_count += 1
			var device: int = player_select.get_index()
			var team: int = player_select.team
			var shape: int = player_select.shape
			var player_info: = PlayerInfo.new()
			player_info.device = device
			player_info.shape = shape
			if !teams.has(team):
				teams[team] = []
			teams[team].append(player_info)
			
	for ai_button in AIButtons:
		if ai_button.value > 0:
			player_enabled_count += ai_button.value
			for _i in range(0, ai_button.value):
				var device: = -1
				var shape: = 0
				var player_info: = PlayerInfo.new()
				player_info.device = device
				player_info.shape = shape
				player_info.ai = true
				var team: = int(ai_button.name[-1]) - 1
				if !teams.has(team):
					teams[team] = []
				teams[team].append(player_info)
				
	var min_player_count: = 2
	var min_team_count: = 2
	var team_count: = teams.keys().size()
	if team_count >= min_team_count && player_enabled_count >= min_player_count:
		StartButton.set_disabled(false)
		if !is_real:
			return
		_has_started = true
		for player_select in player_selects:
			player_select.set_process_input(false)
		Game.emit_signal("start_game", teams)
	else:
		StartButton.set_disabled(true)

func _on_AITeamButton_value_changed(_value: int, _team: int) -> void:
	check_ready(false)

func _on_StartButton_pressed() -> void:
	check_ready(true)
