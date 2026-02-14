extends State
class_name DeadPirateAntiAir
@export var trail: Sprite2D
@export var hitbox: CollisionShape2D

func enter():
	animation.play("anti_air")
	
func exit():
	trail.visible = false
	hitbox.set_deferred("disabled", true)

func Update(delta: float):
	enemy_can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, player.attacks.pick_random())

func Physics_Update(delta: float):
	pass
