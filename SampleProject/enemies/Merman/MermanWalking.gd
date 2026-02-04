extends State
class_name MermanWalking
@export var walking_timer: Timer
@export var SPEED: float
const WALKING_MIN_DURATION: float = 0.5
const WALKING_MAX_DURATION: float = 1.5

func _ready() -> void:
	walking_timer.timeout.connect(Transitioned.emit.bind(self, "fire"))

func enter():
	can_turnaround_with_scale()
	var walking_duration: float = randf_range(WALKING_MIN_DURATION, WALKING_MAX_DURATION)
	player.velocity.x = SPEED*player.facing_position
	walking_timer.wait_time = walking_duration
	walking_timer.start()
	animation.play("walking")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass
