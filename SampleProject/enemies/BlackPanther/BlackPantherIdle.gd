extends State
class_name BlackPantherIdle

func enter():
	animation.play("idle", -1, 1)
	
func Update(delta: float):
	if player.activated_AI:
		Transitioned.emit(self, "running")
		player.vision.set_deferred("disabled", true)
		
func Physics_Update(delta: float):
	pass
		
func _on_area_of_vision_body_entered(body: Node2D) -> void:
	player.activated_AI = true
