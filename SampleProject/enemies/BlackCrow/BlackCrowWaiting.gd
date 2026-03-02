extends State
class_name BlackCrowWaiting

func enter():
	animation.play("waiting")
	
func exit():
	player.vision.set_deferred("monitoring", false)
	
func Update(delta: float):
	enemy_can_die()
	can_turnaround_with_scale()
	if player.ai_activated:
		sound.play_sound_effect_from_library("move")
		animation.play("fly")
		Transitioned.emit(self, "moving")


func Physics_Update(delta: float):
	pass


func _on_vision_area_entered(area: Area2D) -> void:
	player.ai_activated = true
