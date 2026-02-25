extends State
class_name IceWolfIdle
const MIN_DURATION: float = 0.4
const MAX_DURATION: float = 0.8
var can_act: bool
const JAB_RANGE: float = 100
const SLIDE_RANGE: float = 200
const PROJECTILE_AFTER_RANGE: float = 400

func enter():
	can_act = false
	animation.play("idle")
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(Transitioned.emit.bind(self, decideAction()))
	
func exit():
	pass

func Update(delta: float):
	can_turnaround_with_scale()
	enemy_can_die()

func Physics_Update(delta: float):
	pass

func decideAction() -> String:
	var possible_actions: Array[String] = ["jab", "step", "projectile", "charge", "slide", "jump"]
	if horizontal_distance_from_player() <= JAB_RANGE:
		possible_actions.erase("projectile")
		possible_actions.erase("charge")
		possible_actions.erase("step")
	else:
		possible_actions.erase("jab")
		
	if horizontal_distance_from_player() > SLIDE_RANGE:
		possible_actions.erase("slide")
		possible_actions.erase("jump")
	else:
		possible_actions.erase("projectile")
		
	if horizontal_distance_from_player() >= PROJECTILE_AFTER_RANGE:
		return ["projectile", "step"].pick_random()
		
	return possible_actions.pick_random()
