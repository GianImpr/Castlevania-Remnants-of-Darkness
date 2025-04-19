extends State
class_name ArmorKnightDying

func enter():
	player.velocity.x = 0
	animation.play("dying", -1, 1)
	
func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	pass
