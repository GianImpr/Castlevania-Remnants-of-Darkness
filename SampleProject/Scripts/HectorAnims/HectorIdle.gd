extends State
class_name HectorIdle

const ANIM_SPEED: float = 0.65
const BLEND: float = -1
var can_perfect_guard: bool = true

func enter():
	animation.play(player.Animations.IDLE, BLEND, ANIM_SPEED)
	
func Update(delta: float):
	can_perform(Actions.JUMP, true)
	can_perform(Actions.BACKDASH, true)
	can_perform(Actions.CROUCH, false)
	check_is_hurt()
	can_guard()
	can_attack()
	can_die()
	run_without_start_anim(false)
	can_fall(true)
