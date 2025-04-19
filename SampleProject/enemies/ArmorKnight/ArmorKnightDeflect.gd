extends State
class_name ArmorKnightSwingDeflect

func enter():
	player.velocity.x = 0
	animation.play("deflect", -1, 2)

func exit():
	player.deflect_projectile = false
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "ready")
		
func Physics_Update(delta: float):
	enemy_can_die()
