extends State
class_name BansheeAppearing

func enter():
	animation.play("appearing", -1, 1)
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "moving")
		
func Physics_Update(delta: float):
	enemy_can_die()
