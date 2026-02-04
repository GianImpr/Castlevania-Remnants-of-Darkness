extends State
class_name MermanRecoil

func enter():
	player.velocity.x = 0
	animation.play("recoil")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	
	if not animation.is_playing() and player.is_on_floor():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
