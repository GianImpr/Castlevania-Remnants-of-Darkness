extends State
class_name DragonZombieIdle
const MIN_DURATION: float = 0.5
const MAX_DURATION: float = 1

func enter():
	animation.play("idle")
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(Transitioned.emit.bind(self, decideAction()))
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass

func decideAction() -> String:
	if abs(player.global_position.x - Global.camera.limit_left) < player.MINIMUM_DISTANCE:
		return "move"
	return ["move", "breath", "laser", "bite"].pick_random()
