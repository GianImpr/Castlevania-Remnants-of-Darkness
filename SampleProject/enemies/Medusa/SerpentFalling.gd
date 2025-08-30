extends State
class_name SerpentFalling

func enter():
	animation.play("falling")
	
func exit():
	pass

func Update(delta: float):
	can_turnaround_with_scale()
	enemy_can_die(false)
	if player.is_on_floor():
		Transitioned.emit(self, "walking")

func Physics_Update(delta: float):
	pass
