extends State
class_name HectorAttack
var can_perfect_guard: bool = false

func enter():
	if not player.resume_attack:
		animation.play("attack" + attack_anim_suffix(), -1, get_attack_speed())
	else:
		var old_anim_pos = animation.current_animation_position
		animation.play("attack" + attack_anim_suffix(), -1, get_attack_speed())
		animation.seek(old_anim_pos)
		if player.sprite.weapon != null:
			player.sprite.weapon.set_anim_pos(player.sprite.weapon.anim_position)
		player.resume_attack = false
		
	
func exit():
	if player.sprite.weapon != null:
		player.sprite.weapon.stop()
	
func Update(delta: float):
	remove_momentum()
	
func Physics_Update(delta: float):
	can_perform("backdash", true)
	can_fall(true)
	check_is_hurt()
	can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
