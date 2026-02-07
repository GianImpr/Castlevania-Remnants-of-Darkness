extends State
class_name FrozenShadeIdle
var duration: float
const MIN_DURATION: float = 0.2
const MAX_DURATION: float = 1
const ACTIONS: Array[String] = ["icicle", "freeze"]
var can_act: bool

func enter():
	animation.play("idle")
	can_act = false
	duration = randf_range(MIN_DURATION, MAX_DURATION)
	get_tree().create_timer(duration, false).timeout.connect(func(): can_act = true)
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if sign(player.facing_position) != sign(Global.player.global_position.x - player.global_position.x):
		Transitioned.emit(self, "turning")
		
	if can_act and player.activated_AI:
		Transitioned.emit(self, decideAction())


func Physics_Update(delta: float):
	pass

func decideAction() -> String:
	return ACTIONS.pick_random()
