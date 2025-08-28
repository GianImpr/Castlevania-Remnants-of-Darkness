extends State
class_name MedusaIdle
@export_range(0, 2, 0.1, "suffix:s") var idle_duration_time: float
@export_range(0, 2, 0.1, "suffix:s") var idle_duration_offset: float
@export var idle_timer: Timer

func enter():
	animation.play("idle")
	idle_timer.wait_time = idle_duration_time + randf_range(-idle_duration_offset, idle_duration_offset)
	idle_timer.start()
	idle_timer.timeout.connect(player.decideAction)

func exit():
	idle_timer.stop()

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass
