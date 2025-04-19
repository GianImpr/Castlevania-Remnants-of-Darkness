extends State
class_name HectorRise
@export var run_state: State 
var can_perfect_guard: bool = true


func enter():
	animation.play("crouch", -1, -1.8, true)
	animation.seek(0.1)
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_perform("crouch", false)
	can_perform("jump", true)
	can_perform("backdash", true)
	run_without_start_anim(false)
	can_fall(true)
	check_is_hurt()
	can_attack()
	can_guard()
	can_die()
		
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
