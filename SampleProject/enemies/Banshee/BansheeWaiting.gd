extends State
class_name BansheeWaiting
@export var hitbox: CollisionShape2D
@export var hurtbox: CollisionShape2D

func enter():
	animation.play("waiting", -1, 1)
	
func Update(delta: float):
	if player.activated_AI:
		Transitioned.emit(self, "appearing")
		player.vision.set_deferred("disabled", true)
		hitbox.set_deferred("disabled", false)
		hurtbox.set_deferred("disabled", false)
		
func Physics_Update(delta: float):
	pass
		
func _on_area_of_vision_body_entered(body: Node2D) -> void:
	player.activated_AI = true
