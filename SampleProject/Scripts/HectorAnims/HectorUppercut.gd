extends State
class_name HectorUppercut
var can_perfect_guard: bool = false
const CANCELABLE_FROM: float = 0.4

func enter():
	animation.play("uppercut")
	remove_momentum()
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	can_perform("backdash", true)
	can_fall(true)
	check_is_hurt()
	can_die()
	
	if Input.is_action_just_pressed("attack") and Input.is_action_pressed("guard") and animation.current_animation_position >= CANCELABLE_FROM:
		animation.seek(0)
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
