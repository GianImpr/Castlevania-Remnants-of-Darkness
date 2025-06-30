extends State
class_name UneGrowing

func enter():
	animation.play("growing", -1, 1)
	
func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	enemy_can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
