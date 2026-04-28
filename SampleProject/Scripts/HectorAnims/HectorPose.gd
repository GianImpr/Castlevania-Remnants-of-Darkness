extends State
class_name HectorPose
var can_perfect_guard: bool = true

func enter():
	animation.play("pose")
	
func Update(delta: float):
	if not Input.is_action_pressed("up_arrow"):
		Transitioned.emit(self, "idle")
		
	if not animation.is_playing():
		animation.play("pose_loop")
		
	can_perform(Actions.JUMP, true)
	can_perform(Actions.BACKDASH, true)
	can_perform(Actions.CROUCH, false)
	check_is_hurt()
	can_guard()
	can_attack()
	can_die()
	run_without_start_anim(false)
	can_fall(true)
