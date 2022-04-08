extends Label

signal time_up

var time_start: = 120000
var time: = time_start
var is_overtime: = false
var _second: = 0
var _second_threshold: = 1000
var _soon_over_threshold: = _second_threshold * 11

func _ready() -> void:
	stop_timer()
	update_text()

func _physics_process(delta: float) -> void:
	# debug
#	time = time_start
	update_text()
	var step: = int(delta * 1000)
	if is_overtime:
		time += step
	else:
		time -= step
		
		if time <= _soon_over_threshold && time >= 0:
			if _second >= _second_threshold:
				Audio.play("TimerBlip")
				_second = 0
			_second += step
			
		if time <= 0:
			_time_up()

# warning-ignore-all:integer_division
func update_text() -> void:
#	var milliseconds: = str((time % 1000)).pad_zeros(3)
	var seconds: = str((time / 1000) % 60).pad_zeros(2)
	var minutes: = str((time / (1000 * 60)) % 60).pad_zeros(1)
	var plus: = ""
	if is_overtime:
		plus = "+"
	var time_str: = "%s%s:%s" % [plus, minutes, seconds]
	text = time_str

func _time_up() -> void:
	stop_timer()
	emit_signal("time_up")
	if !is_overtime:
		Audio.play("Buzzer")

func start_timer() -> void:
	set_physics_process(true)

func stop_timer() -> void:
	set_physics_process(false)

func reset() -> void:
	_second = 0
	is_overtime = false
	time = time_start
	update_text()

func set_overtime() -> void:
	is_overtime = true
	time = 0
	_second = 0
	update_text()

func check_zero() -> bool:
	if time <= 999:
		return true
	return false
