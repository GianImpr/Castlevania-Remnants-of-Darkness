extends State
class_name HectorGuard
var can_perfect_guard: bool = true


func enter():
	player.velocity.x = 0
	animation.play("raise_guard", -1, 1.2)
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_die()
	can_fall(true)
	check_is_blocking()
	_can_activate_magic()
	
	if Input.is_action_just_pressed("attack") and player.stats.canApplySkill(Skill.Skills.WICKED_GLADIATOR_FIST):
		Transitioned.emit(self, "uppercut")
	elif Input.is_action_just_pressed("attack") and player.stats.canApplySkill(Skill.Skills.CHARGE_ONE) and player.cur_charge == HectorPlayer.Charge.NONE and player.stats.Stats["FP"] == player.stats.Stats["MFP"]:
		player.activateCharge(HectorPlayer.Charge.ONE)
	
	
	if player.direction:
		Transitioned.emit(self, "guard_walk")
	
	if not Input.is_action_pressed("guard"):
		Transitioned.emit(self, "guard_down")
