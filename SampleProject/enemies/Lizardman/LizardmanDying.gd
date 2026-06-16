extends State
class_name LizardmanDying

func enter():
	can_turnaround_with_scale()
	sound.play_sound_effect_from_library("dying")
	animation.play("dying")
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		animation.play("dying")

func Physics_Update(delta: float):
	pass
