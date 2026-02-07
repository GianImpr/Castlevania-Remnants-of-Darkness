extends State
class_name FrozenShadeFreeze

func enter():
	animation.play("freeze")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
