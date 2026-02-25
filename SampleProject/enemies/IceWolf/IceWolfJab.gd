extends State
class_name IceWolfPunch
@export var punch: CollisionShape2D
@export var last_punch: CollisionShape2D

func enter():
	animation.play("flash_punch")
	
func exit():
	punch.set_deferred("disabled", true)
	last_punch.set_deferred("disabled", true)

func Update(delta: float):
	enemy_can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
