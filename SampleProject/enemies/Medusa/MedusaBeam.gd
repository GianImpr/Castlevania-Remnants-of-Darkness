extends State
class_name MedusaBeam

func enter():
	animation.play("laser")

func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass

func shootBeam() -> void:
	pass
