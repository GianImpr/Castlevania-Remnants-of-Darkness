extends State
class_name BatWaking
@export var hitbox_iframe: CollisionShape2D
@export var wake_duration: Timer

func enter():
	wake_duration.start()
	animation.play("waking", -1, 1)
	
func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	enemy_can_die()


func _on_wake_duration_timeout() -> void:
	Transitioned.emit(self, "flying")
