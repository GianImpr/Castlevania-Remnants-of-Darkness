extends State
class_name SkeletonArcherIdle
const MIN_DURATION: float = 0.3
const MAX_DURATION: float = 1
var can_act: bool

func enter():
	animation.play("idle")
	can_act = false
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(func(): can_act = true)
	
func exit():
	pass

func Update(delta: float):
	if player.activated_AI and can_act:
		Transitioned.emit(self, ["walking", "crouching"].pick_random())
		
	enemy_can_die()
	can_turnaround_with_scale()
		
func Physics_Update(delta: float):
	pass
