extends State
class_name ProcelMoving
const DISTANCE: float = 500
const DURATION_SECONDS: float = 3
var moving_tween: Tween

func enter():
	moving_tween = get_tree().create_tween()
	moving_tween.finished.connect(Transitioned.emit.bind(self, "disappearing"))
	moving_tween.set_trans(Tween.TRANS_SINE)
	moving_tween.tween_property(player, "global_position:x", player.default_position.x+DISTANCE*player.facing_position, DURATION_SECONDS)
	
func exit():
	if moving_tween.is_running():
		moving_tween.kill()

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass
