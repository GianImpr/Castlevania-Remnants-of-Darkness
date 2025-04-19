extends State
class_name DullahanWaiting
@export var event_id: int

func enter():
	animation.play("appearing", -1, 0)
	
func Update(delta: float):
	if animation.current_animation_position >= 0.1:
		animation.pause()


func _on_trigger_boss_body_entered(body: Node2D) -> void:
	Global.player.freeze()
	Transitioned.emit(self, "appearing")
	player.trigger_boss.set_deferred("monitoring", false)
