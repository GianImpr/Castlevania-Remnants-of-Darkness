extends State
class_name HectorJump
@export var JUMP_VELOCITY: float
var can_perfect_guard: bool = true


func enter():
	animation.play("jump", -1, 1.3)
	animation.seek(0)
	player.velocity.y = JUMP_VELOCITY
	sound.play_sound_effect_from_library("jump")
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
		
	if not Input.is_action_pressed("jump") and player.velocity.y < 0:
		player.velocity.y *= 0.95*delta
			
	can_move_with_momentum(player.velocity.y < 200)
	can_turn()
	can_attack()
	can_land()
	can_die()
	check_is_blocking()
	check_is_hurt()
