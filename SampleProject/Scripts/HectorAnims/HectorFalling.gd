extends State
class_name HectorFalling
@export var coyote_timer: Timer
@export var trail_timer: Timer
static var cur_falling_speed: float
var can_perfect_guard: bool = true
const FALL_STARTING_ANIM_TIME: float = 0.5
const HARD_LAND_SPEED_THRESHOLD: float = 1000

func enter():
	animation.play("jump", -1, 1.3)
	animation.seek(FALL_STARTING_ANIM_TIME)
	cur_falling_speed = 0
	if abs(player.velocity.x) > abs(player.SPEED):
		trail_timer.start()
		
func exit():
	trail_timer.stop()
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_move_with_momentum(true, true)
	can_turn()
	can_attack()
	if coyote_timer.is_stopped():
		can_double_jump()
	check_is_hurt()
	can_die()
	if not coyote_timer.is_stopped():
		can_perform("jump", true)
	
	determineLandingType()

#Checks if the player will soft land or hard land
#cur_falling_speed is needed because player.velocity.y updates to 0
#BEFORE player.is_on_floor() returns true
func determineLandingType() -> void:
	if player.is_on_floor():
		if cur_falling_speed < HARD_LAND_SPEED_THRESHOLD:
			Transitioned.emit(self, "landing")
		elif cur_falling_speed >= HARD_LAND_SPEED_THRESHOLD:
			Transitioned.emit(self, "hard_landing")
	else:
		cur_falling_speed = player.velocity.y
