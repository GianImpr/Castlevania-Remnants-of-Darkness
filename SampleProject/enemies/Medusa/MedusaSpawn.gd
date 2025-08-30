extends State
class_name MedusaSpawn
@export var vision: Area2D

func enter():
	pass
	
func exit():
	pass

func Update(delta: float):
	can_turnaround_with_scale()
	if not animation.is_playing() and not vision.monitoring:
		Global.player.unfreeze()
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass

func _on_vision_body_entered(body: Node2D) -> void:
	Global.player.freeze()
	animation.play("appear")
	vision.set_deferred("monitoring", false)
