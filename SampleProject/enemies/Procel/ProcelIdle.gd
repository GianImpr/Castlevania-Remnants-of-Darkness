extends State
class_name ProcelIdle
const IDLE_DURATION_SECONDS: float = 0.1

func enter():
	animation.play("idle")
	get_tree().create_timer(IDLE_DURATION_SECONDS, false).timeout.connect(Transitioned.emit.bind(self, "moving"))
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass
