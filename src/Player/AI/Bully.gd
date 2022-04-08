extends PlayerAI.AIMode

var counter: = 0
var counter_limit: = 1

func enter() -> void:
	counter_limit = randi() % 2 + 1
	o._set_random_player()

func exit() -> void:
	counter = 0

func update(_delta: float) -> void:
	o._set_target(o.enemy_player.position)
	
	if o.BoostCooldown.is_stopped():
		o.boost(o.direction_to_target)
		counter += 1
		
	if counter > counter_limit:
		o.set_state(o.state_history[1])
		return
		
	o.move_direction = o.move_direction.linear_interpolate(o.direction_to_target, o.rotation_weight).normalized()
