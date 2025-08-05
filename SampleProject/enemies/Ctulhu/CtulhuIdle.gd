extends State
class_name CtulhuIdle
@export var idle_timer: Timer
@export_range(0, 1, 0.1, "suffix:s") var duration: float
@export_range(0, 1, 0.1, "suffix:s") var random_duration_offset: float

func enter():
	player.velocity = Vector2(0, 0)
	animation.play("idle")
	idle_timer.wait_time = duration + randf_range(-random_duration_offset, random_duration_offset)
	idle_timer.start()
	idle_timer.timeout.connect(func(): Transitioned.emit(self, decideAction()))
	if Global.game.difficulty == Game.Difficulty.CRAZY:
		Transitioned.emit(self, decideAction())
	
func exit():
	idle_timer.stop()

func Update(delta: float):
	can_turnaround_with_scale()
	enemy_can_die()
	if Global.player.stats.Stats["HP"] <= 0:
		Transitioned.emit(self, "mocking")

func Physics_Update(delta: float):
	pass

func decideAction() -> String:
	const actions: Array[String] = ["jumping", "start_flying", "swinging", "fireball"]
	return actions[randi_range(0, actions.size()-1)]
