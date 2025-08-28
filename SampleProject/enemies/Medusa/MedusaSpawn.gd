extends State
class_name MedusaSpawn

func enter():
	animation.play("appear")
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
