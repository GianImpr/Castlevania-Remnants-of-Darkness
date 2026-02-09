extends State
class_name SkeletonArcherThrowing

func enter():
	animation.play("throwing")
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		
	enemy_can_die()

func Physics_Update(delta: float):
	pass
