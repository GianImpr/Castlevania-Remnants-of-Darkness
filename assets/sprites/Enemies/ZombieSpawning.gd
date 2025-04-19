extends State
class_name ZombieSpawning
@export var hitbox_iframe: CollisionShape2D

func enter():
	animation.play("spawning", -1, 1)
	animation.seek(0.1)
	hitbox_iframe.set_deferred("disabled", true)
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "moving")
	
func Physics_Update(delta: float):
	enemy_can_die()
