extends State
class_name HectorCrouchAttack
var can_perfect_guard: bool = false

func enter():
	var anim_speed = get_attack_speed()
	var anim_suffix = attack_anim_suffix()
	if anim_suffix == "_fist":
		anim_speed += 0.5
	animation.play("crouch_attack" + anim_suffix, -1, anim_speed)
	
func exit():
	if player.sprite.weapon != null:
		player.sprite.weapon.stop()
	
func Update(delta: float):
	remove_momentum()
	
func Physics_Update(delta: float):
	can_fall(true)
	check_is_hurt()
	can_die()
	
	if not animation.is_playing():
		stay_crouched()
