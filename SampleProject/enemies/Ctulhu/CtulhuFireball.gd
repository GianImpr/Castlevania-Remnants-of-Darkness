extends State
class_name CtulhuFireball

func enter():
	can_turnaround_with_scale()
	player.velocity.x = 0
	animation.play("ground_fireball")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
