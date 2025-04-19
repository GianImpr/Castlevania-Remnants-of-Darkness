extends State
class_name ArmorKnightWalk
@export var walk_speed: float

func enter():
	animation.play("walking", -1, 1)
	if randi_range(0, 1) == 1:
		turn_around()
	player.velocity.x = walk_speed * player.facing_position
	
func Update(delta: float):
	if player.activated_AI:
		player.vision.set_deferred("disabled", true)
		Transitioned.emit(self, "ready")
		
	if player.deflect_projectile:
		Transitioned.emit(self, "deflect")
	
	if not animation.is_playing():
		player.velocity.x = 0
		Transitioned.emit(self, "idle")
		
func Physics_Update(delta: float):
	enemy_can_die()
		
func _on_area_of_vision_body_entered(body: Node2D) -> void:
	player.activated_AI = true
