extends State
class_name SkeletonArcherCrouching

const MIN_DURATION: float = 0.3
const MAX_DURATION: float = 1
var can_act: bool

func enter():
	animation.play("crouch")
	can_act = false
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(func(): can_act = true)
	
func exit():
	pass

func Update(delta: float):
	if can_act:
		Transitioned.emit(self, ["crouch_throwing"].pick_random())
		
	enemy_can_die()
	can_turnaround_with_scale()
		
func Physics_Update(delta: float):
	pass
