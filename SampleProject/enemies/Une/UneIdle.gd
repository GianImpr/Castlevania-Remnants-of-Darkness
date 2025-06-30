extends State
class_name UneIdle

func enter():
	animation.play("idle", -1, 1)
	
func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	enemy_can_die()
