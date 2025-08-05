extends State
class_name ZombieDying
@export var hitbox_iframe: CollisionShape2D

func enter():
	animation.play("dying", -1, 2.7)
	player.velocity.x = 0
	hitbox_iframe.set_deferred("disabled", true)
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	if not animation.is_playing():
		player.queue_free()
