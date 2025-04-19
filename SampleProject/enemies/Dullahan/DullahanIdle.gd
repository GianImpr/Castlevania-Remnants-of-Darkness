extends State
class_name DullahanIdle
@export var idle_duration: Timer

func enter():
	animation.play("idle")
	if not (player.phase_two or Global.game.difficulty == Global.game.Difficulty.CRAZY):
		idle_duration.wait_time = randf_range(0.2, 0.5)
	else:
		idle_duration.wait_time = 0.1
	idle_duration.start()
	
func Update(delta: float):
	can_turnaround_with_scale()
	enemy_can_die(false)


func _on_duration_timeout() -> void:
	var action: String = player.decide_action(1)
	Transitioned.emit(self, action)
