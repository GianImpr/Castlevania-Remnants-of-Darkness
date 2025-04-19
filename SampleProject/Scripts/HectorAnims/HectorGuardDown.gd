extends State
class_name HectorGuardDown
var can_perfect_guard: bool = true

func enter():
	animation.play_backwards("raise_guard")
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_perform("jump", true)
	can_perform("backdash", true)
	can_perform("crouch", false)
	can_attack()
	can_die()
	run_without_start_anim(false)
	can_fall(true)
	check_is_hurt()
	can_guard()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
 
