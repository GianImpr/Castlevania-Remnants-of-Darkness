extends State
class_name BlackPantherIdle

func enter():
	animation.play("idle", -1, 1)
	
func Update(delta: float):
	can_turnaround_with_scale()
	if player.activated_AI:
		Transitioned.emit(self, "running")
		player.vision.set_deferred("disabled", true)
		
func Physics_Update(delta: float):
	enemy_can_die()
		

func _on_vision_area_entered(area: Area2D) -> void:
	player.activated_AI = true
