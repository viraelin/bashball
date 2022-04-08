extends Node

var individual_audio_limit: = 4
var active_sounds: = []

var library: = {
	"Hit": preload("res://src/Audio/Hit.tscn"),
	"HitWall": preload("res://src/Audio/HitWall.tscn"),
	"Boost": preload("res://src/Audio/Boost.tscn"),
	"Goal": preload("res://src/Audio/Goal.tscn"),
	"CountdownBlip": preload("res://src/Audio/CountdownBlip.tscn"),
	"CountdownGo": preload("res://src/Audio/CountdownGo.tscn"),
	"Buzzer": preload("res://src/Audio/Buzzer.tscn"),
	"Winner": preload("res://src/Audio/Winner.tscn"),
	"TimerBlip": preload("res://src/Audio/TimerBlip.tscn"),
}

var system_library: = {
	"MenuMove": preload("res://src/Audio/MenuMove.tscn"),
	"MenuConfirm": preload("res://src/Audio/MenuMove.tscn"),
	"MenuBack": preload("res://src/Audio/MenuMove.tscn"),
	"MenuOptionsValueChange": preload("res://src/Audio/MenuMove.tscn"),
}

var Timers: Node

func _ready() -> void:
	Timers = Node.new()
	Timers.name = "Timers"
	add_child(Timers)
	
	for key in library:
		var timer: = Timer.new()
		timer.name = key
		timer.one_shot = true
		timer.autostart = false
		timer.wait_time = 0.1
		timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
		Timers.add_child(timer)

func play(key: String, pitch: = 1.0, volume: = 0.0) -> void:
	if !library.has(key):
		return
	if active_sounds.count(key) > individual_audio_limit:
		return
	var timer: Timer = Timers.get_node(key)
	if !timer.is_stopped():
		return
		
	timer.start()
	var volume_range: = 5.0
	volume = clamp(volume, -volume_range, volume_range)
	
	var instance: AudioStreamPlayer = library.get(key).instance()
	instance.pause_mode = PAUSE_MODE_PROCESS
	instance.pitch_scale = pitch
	instance.volume_db += volume
	instance.connect("finished", instance, "queue_free")
	instance.connect("finished", self, "_on_instance_finished", [key])
	add_child(instance)
	instance.play()
	# note: sounds are shared here so avoid name collisions across libraries
	active_sounds.append(key)

func play_system_sound(key: String) -> void:
	if !system_library.has(key):
		return
	if active_sounds.count(key) > individual_audio_limit:
		return
		
	var instance: AudioStreamPlayer = system_library.get(key).instance()
	instance.pause_mode = PAUSE_MODE_PROCESS
	instance.volume_db -= 5
	var pitch: = rand_range(0.9, 1.1)
	instance.pitch_scale = pitch
	instance.connect("finished", instance, "queue_free")
	instance.connect("finished", self, "_on_instance_finished", [key])
	add_child(instance)
	instance.play()
	active_sounds.append(key)

func _on_instance_finished(key: String) -> void:
	active_sounds.erase(key)
