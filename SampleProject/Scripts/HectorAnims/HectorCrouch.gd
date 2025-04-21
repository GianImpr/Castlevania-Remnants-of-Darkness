extends State
class_name HectorCrouch
@export var reset_pos_timer: Timer
var can_perfect_guard: bool = false

func enter():
	animation.play("crouch", -1, 2.9)
	if player.skip_crouch_anim:
		animation.seek(0.4)
		player.skip_crouch_anim = false
	player.velocity.x = 0

func Update(delta: float):
	if not Input.is_action_pressed("crouch"):
		Transitioned.emit(self, "rise")
		
	can_turn()
	can_fall(false)
	can_attack()
	can_guard()
	check_is_hurt()
	can_die()
	can_drop_ledge()
	
func Physics_Update(delta: float):
	pass
