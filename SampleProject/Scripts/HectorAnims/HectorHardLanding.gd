extends State
class_name HectorHardLanding
var can_perfect_guard: bool = false

func enter():
	animation.play("hard_landing", -1, 1.7)
	sound.play_sound_effect_from_library("hard_landing")
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):		
	player.velocity.x *= 0.3
	can_fall(false)
	can_die()
	if not animation.is_playing():
		Transitioned.emit(self, "crouch")
		player.is_hurt = false
