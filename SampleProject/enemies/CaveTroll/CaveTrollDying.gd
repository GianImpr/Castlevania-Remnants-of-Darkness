extends State
class_name CaveTrollDying
const SPEED: Vector2 = Vector2(-300, -350)

func enter():
	animation.play("dying")
	player.velocity.x = SPEED.x*player.facing_position
	player.velocity.y = SPEED.y
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass
