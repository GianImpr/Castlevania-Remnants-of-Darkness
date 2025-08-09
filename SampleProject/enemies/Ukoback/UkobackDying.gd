extends State
class_name UkobackDying
const DECELERATION_DURATION: float = 0.3

func enter():
	animation.play("dying")
	get_tree().create_tween().tween_property(player, "velocity", Vector2.ZERO, DECELERATION_DURATION)
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass
