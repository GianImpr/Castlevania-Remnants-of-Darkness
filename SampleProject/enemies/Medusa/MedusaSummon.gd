extends State
class_name MedusaSummon
@export var snake_scene: PackedScene

func enter():
	animation.play("summon")
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
	
func summonSnakes() -> void:
	pass
