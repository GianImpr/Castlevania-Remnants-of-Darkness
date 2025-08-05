extends State
class_name FloatingSkullIdle

func enter():
	player.velocity = Vector2(0, 0)
	animation.play("biting")
	
func Update(delta: float):
	can_turnaround_with_scale()
	enemy_can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "moving")

func Physics_Update(delta: float):
	pass
