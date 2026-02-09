extends State
class_name SkeletonArcherWalking
const MIN_DURATION: float = 0.3
const MAX_DURATION: float = 1
var can_act: bool
@export var SPEED: float
var walking_direction: int = 1

func enter():
	if randi_range(0,1) == 0:
		walking_direction *= -1
	animation.play("walking")
	player.velocity.x = SPEED*player.facing_position*walking_direction
	can_act = false
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(func(): can_act = true)
	
func exit():
	player.velocity.x = 0

func Update(delta: float):
	if can_act:
		Transitioned.emit(self, ["crouch", "throwing"].pick_random())
		
	enemy_can_die()
	can_turnaround_with_scale()
		
func Physics_Update(delta: float):
	pass
