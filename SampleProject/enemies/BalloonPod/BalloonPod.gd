extends State
class_name BalloonPodIdle

func enter():
	if player.flying:
		animation.play("idle_flying")
	else:
		animation.play("idle")
		
func exit():
	pass

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass
