extends State
class_name DullahanWalking
@export var walk_duration: Timer
var direction: int = 1
@export var speed: float

func enter():
	animation.play("walking")
	player.velocity.x = speed * direction * player.facing_position
	walk_duration.wait_time = randf_range(0.5, 1.5)
	walk_duration.start()
	
func exit():
	player.velocity.x = 0
	
func Update(delta: float):
	can_turnaround_with_scale()
	enemy_can_die()


func _on_duration_timeout() -> void:
	var action: String = player.decide_action(2)
	Transitioned.emit(self, action)
