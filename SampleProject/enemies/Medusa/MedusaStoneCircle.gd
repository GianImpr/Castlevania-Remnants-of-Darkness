extends State
class_name MedusaStoneCircle
@export var stone_circle_scene: PackedScene

func enter():
	animation.play("magic")
	sound.play_sound_effect_from_library("damn")
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
