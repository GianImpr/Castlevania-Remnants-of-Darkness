extends State
class_name SerpentWalking
@export var speed: float

func enter():
	animation.play("walking")
	
func exit():
	pass

func Update(delta: float):
	player.velocity.x = speed * player.facing_position
	enemy_can_die()
	if player.ray_cast_2d_left.is_colliding():
		turn_around()

func Physics_Update(delta: float):
	pass
