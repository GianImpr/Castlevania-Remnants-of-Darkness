extends State
class_name GhostIdle
@export var area: Area2D
const HITBOX_ACTIVATE_DELAY: float = 1

func enter():
	animation.play("spawn", -1, 2)
	area.monitoring = false
	
func exit():
	get_tree().create_timer(HITBOX_ACTIVATE_DELAY, false).timeout.connect(area.set_deferred.bind("monitoring", true))
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "move")

func Physics_Update(delta: float):
	pass
