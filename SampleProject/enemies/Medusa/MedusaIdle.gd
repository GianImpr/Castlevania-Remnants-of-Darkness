extends State
class_name MedusaIdle
@export_range(0, 2, 0.1, "suffix:s") var idle_duration_time: float
@export_range(0, 2, 0.1, "suffix:s") var idle_duration_offset: float
@export var idle_timer: Timer
@export var speed: float

func enter():
	player.velocity.x = speed * player.facing_position * randi_range(0, 1)*2-1
	can_turnaround_with_scale()
	animation.play("move")
	idle_timer.wait_time = idle_duration_time + randf_range(-idle_duration_offset, idle_duration_offset)
	idle_timer.start()
	if not idle_timer.timeout.is_connected(player.decideAction):
		idle_timer.timeout.connect(player.decideAction)

func exit():
	player.velocity.x = 0
	idle_timer.stop()

func Update(delta: float):
	enemy_can_die(false)

func Physics_Update(delta: float):
	pass
