extends MenuState
class_name InvClosed

func enter():
	animation.speed_scale = 2
	animation.play("fade_resume")
	
func exit():
	animation.speed_scale = 3
	animation.play_backwards("fade")

func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	pass
