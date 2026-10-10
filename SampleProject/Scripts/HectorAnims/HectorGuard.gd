extends State
class_name HectorGuard
var can_perfect_guard: bool = true
const LAST_GUARD_FRAME: int = 222
static var skip_guard_anim: bool = false

func enter():
	player.velocity.x = 0
	if skip_guard_anim:
		animation.stop()
		player.sprite.frame = LAST_GUARD_FRAME
		skip_guard_anim = false
	else:
		animation.play("raise_guard", -1, 1.2)
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_die()
	can_fall(true)
	check_is_blocking()
	_can_activate_magic()
	
	if Input.is_action_just_pressed("attack") and player.stats.canApplySkill(Skill.Skills.CHARGE_ONE) and player.cur_charge == HectorPlayer.Charge.NONE and player.stats.Stats["FP"] == player.stats.Stats["MFP"]:
		player.activateCharge(HectorPlayer.Charge.ONE)
	
	
	if player.direction:
		Transitioned.emit(self, "guard_walk")
	
	if not Input.is_action_pressed("guard"):
		Transitioned.emit(self, "guard_down")
		
	if Input.is_action_pressed("crouch"):
		Transitioned.emit(self, "guard_crouch")
