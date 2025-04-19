extends State
class_name AxeArmorIdle
@export var hitbox_iframe: CollisionShape2D

func enter():
	animation.play("idle", -1, 1)
	
func Update(delta: float):
	if player.activated_AI:
		Transitioned.emit(self, "moving")
		player.vision.set_deferred("disabled", true)
		
func Physics_Update(delta: float):
	enemy_can_die()


func _on_area_of_vision_body_entered(body: Node2D) -> void:
	player.activated_AI = true
