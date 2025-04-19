extends State
class_name HectorRunEnd
var can_perfect_guard: bool = true


func enter():
	animation.play("run_end", -1, 1.5)
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		
	run_without_start_anim(false)
	can_fall(true)
	can_perform("crouch", false)
	can_perform("jump", true)
	can_perform("backdash", true)
	can_attack()
	check_is_hurt()
	can_guard()
	can_die()
