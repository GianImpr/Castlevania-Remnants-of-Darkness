extends State
class_name SerpentDying
@export var hitbox: CollisionShape2D

func enter():
	player.sprite.visible = false
	player.velocity = Vector2.ZERO
	hitbox.set_deferred("disabled", true)
	
func exit():
	pass

func Update(delta: float):
	if not player.blood_particles.emitting:
		player.queue_free()

func Physics_Update(delta: float):
	pass
