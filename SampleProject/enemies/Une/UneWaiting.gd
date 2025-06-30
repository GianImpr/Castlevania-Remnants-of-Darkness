extends State
class_name UneWaiting

func enter():
	animation.play("waiting", -1, 1)
	
func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	enemy_can_die()
		
func _on_area_of_vision_body_entered(body: Node2D) -> void:
	Transitioned.emit(self, "growing")
	player.vision.set_deferred("disabled", true)
