extends State
class_name BlackPantherDying
@export var SPEED: Vector2

func enter():
	player.velocity.x = SPEED.x * player.facing_position * (-1)
	player.velocity.y = SPEED.y
	animation.play("dying", -1, 1)
	
func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	player.velocity += player.get_gravity() * delta
