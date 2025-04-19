extends State
class_name ArmorKnightIdle

func enter():
	animation.play("idle")
	if Global.game.difficulty == Global.game.Difficulty.CRAZY:
		animation.speed_scale = 1.5
	
func Update(delta: float):
	if player.activated_AI:
		player.vision.set_deferred("disabled", true)
		Transitioned.emit(self, "ready")
	elif not animation.is_playing():
		Transitioned.emit(self, "walk")
		
	if player.deflect_projectile:
		Transitioned.emit(self, "deflect")
		
func Physics_Update(delta: float):
	enemy_can_die()
		
func _on_area_of_vision_body_entered(body: Node2D) -> void:
	player.activated_AI = true
