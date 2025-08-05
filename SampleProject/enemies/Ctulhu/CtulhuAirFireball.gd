extends State
class_name CtulhuAirFireball

func enter():
	can_turnaround_with_scale()
	player.velocity.x = 0
	animation.play("air_fireball")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing():
		Transitioned.emit(self, "landing")

func Physics_Update(delta: float):
	pass
