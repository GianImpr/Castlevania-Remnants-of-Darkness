extends State
class_name HectorAttack
var can_perfect_guard: bool = false

func _ready():
	HectorWait.resumeAttackAnimation = resumeAttackAnimation

func enter():
	if not player.resume_attack:
		animation.play("attack" + attack_anim_suffix(), -1, get_attack_speed())
	else:
		resumeAttackAnimation()
	
func exit():
	if player.sprite.weapon != null:
		player.sprite.weapon.stop()
	
func Update(delta: float):
	remove_momentum()
	
	#Executioner's Hand
	if player.stats.canApplySkill(8) and animation.current_animation_position > 0.6 and InputBuffer.is_action_press_buffered("attack"):
		animation.seek(0)
		player.sprite.weapon.set_anim_pos(0)
		get_hector_attack_sound()
		get_attack_sound()
		enter()
	
func Physics_Update(delta: float):
	can_perform("backdash", true)
	can_fall(true)
	check_is_hurt()
	can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

#Continues the attack animation from where AirAttack left off
func resumeAttackAnimation() -> void:
	var old_anim_pos = animation.current_animation_position
	animation.play("attack" + attack_anim_suffix(), -1, get_attack_speed())
	animation.seek(old_anim_pos)
	if player.sprite.weapon != null:
		player.sprite.weapon.set_anim_pos(player.sprite.weapon.anim_position)
	player.resume_attack = false
