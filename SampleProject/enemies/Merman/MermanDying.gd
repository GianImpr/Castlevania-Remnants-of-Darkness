extends State
class_name MermanDying
@export var SPEED: Vector2

func enter():
	can_turnaround_with_scale()
	player.velocity = SPEED
	player.velocity.x *= player.facing_position
	player.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	animation.play("dying")
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	player.velocity += player.get_gravity()/1.2 * delta
