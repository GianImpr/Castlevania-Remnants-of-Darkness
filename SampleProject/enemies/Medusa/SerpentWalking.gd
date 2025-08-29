extends State
class_name SerpentWalking
@export var speed: float

func enter():
	animation.play("walking")
	player.velocity.x = speed * player.facing_position
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	

func Physics_Update(delta: float):
	pass
