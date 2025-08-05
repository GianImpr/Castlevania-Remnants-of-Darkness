extends State
class_name KamikazeRavenIdle

func enter():
	animation.play("idle")
	
func exit():
	pass

func Update(delta: float):
	can_turnaround_with_scale()
	enemy_can_die()
	if player.activated_AI:
		Transitioned.emit(self, "preparing")

func Physics_Update(delta: float):
	pass
