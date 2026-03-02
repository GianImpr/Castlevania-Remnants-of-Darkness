extends State
class_name BansheeWaiting
@export var hitbox: CollisionShape2D
@export var hurtbox: CollisionShape2D

func enter():
	if Global.game.difficulty == Game.Difficulty.CRAZY:
		animation.speed_scale = 1.5
	animation.play("waiting", -1, 1)
	
func Update(delta: float):
	if player.activated_AI:
		Transitioned.emit(self, "appearing")
		player.vision.set_deferred("disabled", true)
		hitbox.set_deferred("disabled", false)
		hurtbox.set_deferred("disabled", false)
		
func Physics_Update(delta: float):
	pass
		
func _on_vision_area_entered(area: Area2D) -> void:
	player.activated_AI = true
