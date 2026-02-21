extends State
class_name CaveTrollTongue
@export var tongue: CollisionPolygon2D
@export var tongue_sprite: HBoxContainer
var phase: int

func enter():
	animation.play("tongue")
	sound.play_sound_effect_from_library("tongue")
	phase = 0
	tongue_sprite.visible = true
	
func exit():
	tongue.set_deferred("disabled", true)
	tongue_sprite.visible = false

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing() and phase == 0:
		animation.play_backwards("tongue")
		phase = 1
	elif not animation.is_playing() and phase == 1:
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
