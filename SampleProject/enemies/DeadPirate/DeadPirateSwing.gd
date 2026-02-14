extends State
class_name DeadPirateSwing
@export var trail: Sprite2D
@export var hitbox: CollisionShape2D

func enter():
	animation.play("ground_attack")
	
func exit():
	trail.visible = false
	hitbox.set_deferred("disabled", true)

func Update(delta: float):
	enemy_can_die()

	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
