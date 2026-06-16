extends State
class_name IceWolfStep
const SPEED: float = 80
const DURATION: float = 0.6
const DURATION_MIN_MULTIPLIER: int = 1
const DURATION_MAX_MULTIPLIER: int = 2

func enter():
	animation.play("step")
	player.velocity.x = SPEED*player.facing_position
	get_tree().create_timer(DURATION*randi_range(DURATION_MIN_MULTIPLIER, DURATION_MAX_MULTIPLIER), false).timeout.connect(Transitioned.emit.bind(self, "idle"))
	
func exit():
	player.velocity.x = 0

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass
