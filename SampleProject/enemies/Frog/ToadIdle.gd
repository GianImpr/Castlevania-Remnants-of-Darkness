extends State
class_name ToadIdle
const MIN_DURATION: float = 0.2
const MAX_DURATION: float = 1
const MIN_TONGUE_DISTANCE: float = 90

func enter():
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(Transitioned.emit.bind(self, decideAction()))
	animation.play("idle")
	player.velocity = Vector2.ZERO
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	can_turnaround_with_scale()

func Physics_Update(delta: float):
	pass

func decideAction() -> String:
	if abs(Global.player.global_position.x - player.global_position.x) < MIN_TONGUE_DISTANCE:
		return ["tongue", "jump"].pick_random()
	return "jump"
