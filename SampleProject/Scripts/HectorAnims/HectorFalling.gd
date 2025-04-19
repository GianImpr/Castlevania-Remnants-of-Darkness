extends State
class_name HectorFalling
@export var coyote_timer: Timer
var cur_falling_speed: float
var can_perfect_guard: bool = false


func enter():
	animation.play("jump", -1, 1.3)
	animation.seek(0.5)
	cur_falling_speed = 0
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_move_with_momentum(false)
	can_turn()
	can_attack()
	check_is_hurt()
	can_die()
	if not coyote_timer.is_stopped():
		can_perform("jump", true)
	
	if player.is_on_floor():
		if cur_falling_speed < 1000:
			Transitioned.emit(self, "landing")
		elif cur_falling_speed >= 1000:
			Transitioned.emit(self, "hard_landing")
	else:
		cur_falling_speed = player.velocity.y
