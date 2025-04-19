extends State
class_name ArmorKnightSwingDown

func enter():
	animation.play("attack_below", -1, 1.3)
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "ready")
		
func Physics_Update(delta: float):
	enemy_can_die()
