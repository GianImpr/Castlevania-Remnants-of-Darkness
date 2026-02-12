extends State
class_name ToadTongue
@export var tongue_hitbox: CollisionShape2D

func enter():
	animation.play("tongue")
	
func exit():
	tongue_hitbox.set_deferred("disabled", true)

func Update(delta: float):
	enemy_can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
