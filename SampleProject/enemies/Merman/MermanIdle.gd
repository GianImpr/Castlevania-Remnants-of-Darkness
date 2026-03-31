extends State
class_name MermanIdle
@export var idle_timer: Timer
var should_swim: bool = true
const IDLE_MIN_DURATION: float = 0.2
const IDLE_MAX_DURATION: float = 0.8

func _ready() -> void:
	idle_timer.timeout.connect(Transitioned.emit.bind(self, "walking"))

func enter():
	var idle_duration: float = randf_range(IDLE_MIN_DURATION, IDLE_MAX_DURATION)
	player.velocity.x = 0
	idle_timer.wait_time = idle_duration
	animation.play("idle")
	if player.activated_AI:
		idle_timer.start()
	
func exit():
	pass

func Update(delta: float):
	can_turnaround_with_scale()
	enemy_can_die()
	
	if idle_timer.is_stopped() and player.activated_AI:
		idle_timer.start()

func Physics_Update(delta: float):
	pass
