extends State
class_name DullahanWaiting
@export var event_id: int
@export var dullahan_sprite: Sprite2D

func enter():
	animation.play("appearing", -1, 0)
	dullahan_sprite.material.set_shader_parameter("enabled", false)
	
func Update(delta: float):
	if animation.current_animation_position >= 0.1:
		animation.pause()


func _on_trigger_boss_body_entered(body: Node2D) -> void:
	Global.player.freeze()
	Transitioned.emit(self, "appearing")
	player.trigger_boss.set_deferred("monitoring", false)
