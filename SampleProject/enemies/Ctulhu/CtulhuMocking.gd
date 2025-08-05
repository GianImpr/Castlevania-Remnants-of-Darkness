extends State
class_name CtulhuMocking

func enter():
	sound.play_sound_effect_from_library("mocking")
	player.velocity.x = 0
	animation.play("mocking")
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass
