extends Node2D

var is_antialiased: = false

var points: = [[], [], []]
var lines: = [[], [], []]
var multilines: = [[], [], []]
var rects: = [[], [], []]

var radii: = [1.0, 3.0, 5.0]
var widths: = [1.0, 8.0, 3.0]
var colors: = [Color.red, Color.green, Color.cyan]

func _ready() -> void:
	z_index = 1000

func _physics_process(_delta: float) -> void:
	update()

func _draw() -> void:
	var i: = 0
	for array in points:
		for point in array:
			draw_circle(point, radii[i], colors[i])
		i += 1
		
	i = 0
	for array in lines:
		for line in array:
			draw_circle(line[0], radii[i], colors[i])
			draw_circle(line[1], radii[i], colors[i])
			draw_multiline(line, colors[i], widths[i], is_antialiased)
		i += 1
		
	i = 0
	for array in multilines:
		for multiline in array:
			if multiline.size() > 1:
				draw_circle(multiline[0], radii[i], colors[i])
				draw_circle(multiline[-1], radii[i], colors[i])
				draw_multiline(multiline, colors[i], widths[i], is_antialiased)
		i += 1
		
	i = 0
	for array in rects:
		for rect in array:
			draw_rect(rect, colors[i], false, widths[i], is_antialiased)
		i += 1
		
	for array in points:
		array.clear()
	for array in lines:
		array.clear()
	for array in multilines:
		array.clear()
	for array in rects:
		array.clear()
