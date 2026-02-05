extends State
class_name ProcelDisappearing

func enter():
	animation.play("disappear")
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "hidden")

func Physics_Update(delta: float):
	pass
