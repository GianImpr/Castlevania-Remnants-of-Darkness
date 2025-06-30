extends State
class_name HectorThrowAxe

var can_perfect_guard: bool = false
var axe_thrown: bool

func enter():
	player.playSpecialAttackEffect()
	animation.play("throw", -1, 1)
	axe_thrown = false

func Update(delta: float):
	if animation.current_animation_position > 0.066 and not axe_thrown:
		player.throwAxe()
		axe_thrown = true
	
	can_perform("backdash", true)
	can_fall(true)
	check_is_hurt()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

	
func Physics_Update(delta: float):
	remove_momentum()
