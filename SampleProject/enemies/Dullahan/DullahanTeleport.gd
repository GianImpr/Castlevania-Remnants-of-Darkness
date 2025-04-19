extends State
class_name DullahanTeleport

@export var min_x_position: float
@export var max_x_position: float

func enter():
	animation.play("teleport")
	
func Update(delta: float):
	can_turnaround_with_scale()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		
func warp() -> void:
	player.global_position.x = randf_range(min_x_position, max_x_position)
