extends State
class_name MedusaSword
const sword_sounds: Array[String] = ["sword_1", "sword_2"]

func enter():
	sound.play_sound_effect_from_library(sword_sounds.pick_random())
	animation.play("sword")
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
