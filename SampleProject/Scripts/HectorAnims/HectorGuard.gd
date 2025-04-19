extends State
class_name HectorGuard
var can_perfect_guard: bool = true


func enter():
	player.velocity.x = 0
	animation.play("raise_guard", -1, 1.2)
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_die()
	can_fall(true)
	check_is_blocking()
	_can_activate_magic()
	
	if player.direction:
		Transitioned.emit(self, "guard_walk")
	
	if not Input.is_action_pressed("guard"):
		Transitioned.emit(self, "guard_down")
