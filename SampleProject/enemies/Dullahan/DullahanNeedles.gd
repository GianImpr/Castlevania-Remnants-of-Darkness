extends State
class_name DullahanNeedles

func enter():
	animation.play("needles")
	can_turnaround_with_scale()
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
