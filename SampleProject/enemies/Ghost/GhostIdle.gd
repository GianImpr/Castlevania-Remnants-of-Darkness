extends State
class_name GhostIdle
@export var area: Area2D

func enter():
	animation.play("spawn", -1, 2)
	area.monitoring = false
	
func exit():
	area.monitoring = true
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "move")

func Physics_Update(delta: float):
	pass
