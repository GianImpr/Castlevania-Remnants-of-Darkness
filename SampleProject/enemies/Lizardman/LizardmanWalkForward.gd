extends State
class_name LizardmanWalkForward
const DURATION: float = 0.7
const MIN_DURATION_MULTIPLIER: int = 1
const MAX_DURATION_MULTIPLIER: int = 3
var can_act: bool
const SPEED: float = 70

func enter():
	animation.play("walk_forward")
	can_turnaround_with_scale()
	player.velocity.x = SPEED*player.facing_position
	can_act = false
	get_tree().create_timer(DURATION*randi_range(MIN_DURATION_MULTIPLIER, MAX_DURATION_MULTIPLIER), false).timeout.connect(func(): can_act = true)
	
func exit():
	player.velocity.x = 0

func Update(delta: float):
	if can_act:
		Transitioned.emit(self, "idle")
	
	enemy_can_die()
	enemy_can_guard(player.should_guard)

func Physics_Update(delta: float):
	pass
