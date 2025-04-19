extends State
class_name HectorLanding
var can_perfect_guard: bool = true


func enter():
	animation.play("landing", -1, 1.3)
	sound.play_sound_effect_from_library("land")
	player.velocity.x = 0
	
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_perform("jump", true)
	run_without_start_anim(false)
	can_perform("crouch", false)
	can_fall(true)
	can_perform("backdash", true)
	can_move_with_momentum(true)
	can_attack()
	can_guard()
	can_die()
	check_is_hurt()
		
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
