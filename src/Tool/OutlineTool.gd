tool
extends Line2D

export(int, 3, 64, 1) var vertices: = 4 setget set_vertices
export(int, 1, 4096, 1) var radius: = 64 setget set_radius
export(float, -360.0, 360.0, 1.0) var angle: = -90.0 setget set_angle

func set_vertices(value: int) -> void:
	vertices = value
	update_polygon()

func set_radius(value: int) -> void:
	radius = value
	update_polygon()

func set_angle(value: float) -> void:
	angle = value
	update_polygon()

func update_polygon() -> void:
	var _points: = Math.create_polygon(Vector2(), vertices, radius, angle)
	_points.append(_points[0])
	set_points(_points)
