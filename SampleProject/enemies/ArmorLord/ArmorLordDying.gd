extends State
class_name ArmorLordDying

func enter():
	player.velocity.x = 0
	animation.play("dying")
	
func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	pass
