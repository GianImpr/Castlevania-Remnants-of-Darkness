extends State
class_name SkeletonArcherCrouchThrowing

func enter():
	animation.play("crouch_throwing")
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "walking")
		
	enemy_can_die()

func Physics_Update(delta: float):
	pass
