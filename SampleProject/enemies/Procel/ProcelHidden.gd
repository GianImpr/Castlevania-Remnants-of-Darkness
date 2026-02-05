extends State
class_name ProcelHidden
const HIDDEN_DURATION: float = 1
var can_show_up: bool

func enter():
	can_show_up = false
	get_tree().create_timer(HIDDEN_DURATION, false).timeout.connect(func(): can_show_up = true)
	animation.play("hidden")
	if player.default_position != Vector2.ZERO:
		player.global_position = player.default_position
	else:
		player.default_position = player.global_position
	
func exit():
	pass

func Update(delta: float):
	if player.activated_AI and can_show_up:
		Transitioned.emit(self, "appearing")

func Physics_Update(delta: float):
	pass
