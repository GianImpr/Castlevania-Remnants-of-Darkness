extends State
class_name HectorGuardCrouch
var can_perfect_guard: bool = false
const LAST_GUARD_FRAME: int = 381
static var skip_guard_anim: bool = false

func enter():
	player.velocity.x = 0
	if skip_guard_anim:
		animation.stop()
		player.sprite.frame = LAST_GUARD_FRAME
		skip_guard_anim = false
	else:
		animation.play("raise_guard_crouch", -1, 1.2)
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_die()
	can_fall(true)
	check_is_blocking()
	
	if not Input.is_action_pressed("crouch"):
		Transitioned.emit(self, "guard")
	
	if not Input.is_action_pressed("guard"):
		player.skip_crouch_anim = true
		Transitioned.emit(self, "crouch")
