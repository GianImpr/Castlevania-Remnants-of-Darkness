extends State
class_name HectorRun

const ANIM_SPEED: float = 1.6
const BLEND: float = -1
const ANIM_NAME: String = "run_start"
var can_perfect_guard: bool = true

func enter():
	if not player.skip_run_start:
		animation.play("run_start", BLEND, 1.6)
	else:
		animation.play("run", BLEND, 1.8)
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	#Continue the run animation if not stopping
	if not animation.is_playing():
		animation.play("run", -1, 1.8)
		
	can_move_with_momentum(false)
	can_perform(Actions.JUMP, true)
	can_perform(Actions.BACKDASH, true)
	can_perform(Actions.CROUCH, false)
	can_attack()
	can_turn()
	can_fall(true)
	check_is_hurt()
	can_guard()
	can_die()
	
	#If stopped moving while you just started running, go to idle state
	if not player.direction and animation.current_animation == "run_start":
		Transitioned.emit(self, "idle")
	elif not player.direction:
		Transitioned.emit(self, "run_end")
