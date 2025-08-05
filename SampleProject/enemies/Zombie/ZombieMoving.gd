extends State
class_name ZombieMoving
@export var SPEED: float = 100
@export var hitbox_iframe: CollisionShape2D

func enter():
	animation.play("moving", -1, 0.5)
	hitbox_iframe.set_deferred("disabled", false)
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	player.velocity.x = SPEED * player.direction * delta
	
	enemy_can_die()
