extends State
class_name HectorStandUp
var can_perfect_guard: bool = false

func enter():
	animation.play_backwards("sitting_down", -1)
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
	
func Physics_Update(delta: float):
	pass
