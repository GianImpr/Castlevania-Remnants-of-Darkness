extends State
class_name BlackCrowIdle
@export var idle_duration: Timer
@export_range(0, 1, 0.1, "suffix: s") var idle_duration_variation: float
const base_duration: float = 1.5

func enter():
	player.velocity = Vector2(0, 0)
	idle_duration.wait_time = base_duration + randf_range(-idle_duration_variation, idle_duration_variation)
	if Global.game.difficulty == Game.Difficulty.CRAZY:
		idle_duration.wait_time /= 2
	idle_duration.start()
	
func exit():
	if not idle_duration.is_stopped():
		idle_duration.stop()
	
func Update(delta: float):
	enemy_can_die()
	can_turnaround_with_scale()

func Physics_Update(delta: float):
	pass

func _on_duration_timeout() -> void:
	Transitioned.emit(self, "moving")
