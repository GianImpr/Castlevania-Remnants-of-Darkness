extends State
class_name MedusaBeam

func enter():
	animation.play("laser")
	sound.play_sound_effect_from_library("stone")

func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		if Global.player.stats.current_status == Global.player.stats.Ailment.STONE:
			Transitioned.emit(self, "dash")
		else:
			Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
