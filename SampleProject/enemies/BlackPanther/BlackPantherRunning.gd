extends State
class_name BlackPantherRunning
@export var SPEED: float

func enter():
	player.velocity.x = SPEED * player.facing_position
	animation.play("running", -1, 1)
	
func Update(delta: float):
	enemy_can_die()
		
func Physics_Update(delta: float):
	if player.ray_cast_2d_left.is_colliding() or player.ray_cast_2d_right.is_colliding():
		turn_around()
		player.velocity.x *= -1
