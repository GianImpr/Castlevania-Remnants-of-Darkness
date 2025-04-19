extends State
class_name HectorAirAttack
var can_perfect_guard: bool = false


func enter():
	animation.play("air_attack" + attack_anim_suffix(), -1, get_attack_speed())
	
func exit():
	if player.sprite.weapon != null and not player.resume_attack:
		player.sprite.weapon.stop()
	elif player.sprite.weapon != null and player.resume_attack:
		player.sprite.weapon.register_anim_pos()
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	if Input.is_action_just_released("jump") and player.velocity.y < 0:
		player.velocity.y *= 0.95*delta
		
	can_move_with_momentum(false)
	check_is_hurt()
	can_land()
	can_die()
	
	if not animation.is_playing() and not player.is_on_floor():
		Transitioned.emit(self, "falling")
