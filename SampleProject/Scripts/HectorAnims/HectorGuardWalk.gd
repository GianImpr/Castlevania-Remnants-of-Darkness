extends State
class_name HectorGuardWalk
var anim_direction: int
var can_perfect_guard: bool = true


func enter():
	anim_direction = 0
	
func Update(delta: float):
	can_die()
	can_fall(true)
	
	if player.direction != anim_direction * player.facing_position:
		updateDirection()
	
	if player.direction == 0 and Input.is_action_pressed("guard"):
		Transitioned.emit(self, "guard")
	elif not Input.is_action_pressed("guard"):
		Transitioned.emit(self, "run")
		
	check_is_blocking()
	_can_activate_magic()
	
func Physics_Update(delta: float):
	player.velocity.x = player.direction * player.SPEED/3
	

func updateDirection():
	anim_direction = player.direction * player.facing_position
	if anim_direction > 0:
		animation.play("guard_walk")
	else:
		animation.play_backwards("guard_walk")
