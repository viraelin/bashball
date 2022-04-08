extends Node2D

onready var displays: = get_children()

func _ready() -> void:
	Game.connect("goal_entered_screen", self, "_on_goal_entered_screen")
	Game.connect("goal_exited_screen", self, "_on_goal_exited_screen")

func _physics_process(_delta: float) -> void:
	if !is_instance_valid(Game.current_camera):
		return
		
	var camera: = Game.current_camera
	var center: = camera.get_camera_screen_center()
	var bounds: = camera.get_viewport_rect()
	bounds.size *= camera.zoom.x
	bounds.position += center - (bounds.size * 0.5)
#	Debug.rects[1].append(bounds)
	
	var tl: = Vector2(bounds.position.x, bounds.position.y)
	var tr: = Vector2(bounds.position.x + bounds.size.x, bounds.position.y)
	var bl: = Vector2(bounds.position.x, bounds.position.y + bounds.size.y)
	var br: = Vector2(bounds.position.x + bounds.size.x, bounds.position.y + bounds.size.y)
	var corners: = [tl, tr, br, bl, tl]
	var offset: = 48.0 * camera.zoom.x
	
	for goal in Game.goals:
		var display: Node2D = displays[goal.team]
		if display.visible:
			var goal_pos: Vector2 = goal.global_position
			var direction: = center.direction_to(goal_pos)
			for j in range(0, corners.size() - 1):
				var p1: Vector2 = corners[j]
				var p2: Vector2 = corners[j+1]
				var collision = Geometry.segment_intersects_segment_2d(center, goal_pos, p1, p2)
				if collision is Vector2:
					var pos: Vector2 = collision
					display.position = pos - (direction * offset)
					display.rotation = direction.angle() + PI/2.0
					display.scale = camera.zoom
#					Debug.points[1].append(pos)
#					Debug.points[2].append(pos)
#					Debug.lines[1].append([center, pos])
#					Debug.lines[2].append([center, goal_pos])
					break

func _on_goal_entered_screen(goal: Node2D) -> void:
	var display: Node2D = displays[goal.team]
	display.hide()

func _on_goal_exited_screen(goal: Node2D) -> void:
	var display: Node2D = displays[goal.team]
	display.set_color(goal.color)
	display.show()
