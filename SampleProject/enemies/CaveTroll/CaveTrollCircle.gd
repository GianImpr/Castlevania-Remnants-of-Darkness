extends State
class_name CaveTrollMagic
@export var aura: CollisionShape2D
@export var aura_sprite: Sprite2D

func enter():
	animation.play("aura")
	aura.set_deferred("disabled", false)
	
func exit():
	aura.set_deferred("disabled", true)
	aura_sprite.visible = false

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
