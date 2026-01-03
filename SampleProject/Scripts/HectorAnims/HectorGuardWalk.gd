extends State
class_name HectorGuardWalk
var anim_direction: int
var can_perfect_guard: bool = true
const WALK_SPEED_MULTIPLIER: float = 0.33


func enter():
	anim_direction = 0
	
func Update(delta: float):
	can_die()
	can_fall(true)
	
	if player.direction != anim_direction * player.facing_position:
		updateDirection()

	if Input.is_action_just_pressed("attack") and player.stats.canApplySkill(Skill.Skills.WICKED_GLADIATOR_FIST):
		Transitioned.emit(self, "uppercut")
	elif Input.is_action_just_pressed("attack") and player.stats.canApplySkill(Skill.Skills.CHARGE_ONE) and player.cur_charge == HectorPlayer.Charge.NONE and player.stats.Stats["FP"] == player.stats.Stats["MFP"]:
		player.activateCharge(HectorPlayer.Charge.ONE)


	if player.direction == 0 and Input.is_action_pressed("guard"):
		Transitioned.emit(self, "guard")
	elif not Input.is_action_pressed("guard"):
		Transitioned.emit(self, "run")
		
	check_is_blocking()
	_can_activate_magic()
	
func Physics_Update(delta: float):
	player.velocity.x = player.direction * player.SPEED*WALK_SPEED_MULTIPLIER
	

#Updates Hector's walking direction alongside adjusting his animation
func updateDirection():
	anim_direction = player.direction * player.facing_position
	if anim_direction > 0:
		animation.play("guard_walk")
	else:
		animation.play_backwards("guard_walk")
