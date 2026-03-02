extends State
class_name HectorDiveKick
@export var trail_timer: Timer
@export var FALLING_SPEED: Vector2
const HARD_LAND_AFTER_SECONDS: float = 0.2
var hard_land: bool
var can_perfect_guard: bool = false
var diagonal: bool

func enter():
	hard_land = false
	trail_timer.start()
	get_tree().create_timer(HARD_LAND_AFTER_SECONDS, false).timeout.connect(func(): hard_land = true)
	if player.direction == 0:
		animation.play("dive_kick_straight")
		diagonal = false
	else:
		animation.play("dive_kick_diagonal")
		diagonal = true
	player.velocity = FALLING_SPEED
	player.velocity.x *= player.direction
	sound.play_sound_effect_from_library("dive_kick")
	
func exit():
	trail_timer.stop()

func Physics_Update(delta: float):
	can_die()
	check_is_hurt()
	
	if player.is_on_floor():
		if hard_land or player.stats.status[player.stats.Status.POISON] > 0:
			Transitioned.emit(self, "hard_landing")
		else:
			if not Input.is_action_pressed("jump") and player.direction == 0 and diagonal:
				Transitioned.emit(self, "front_dash")
			else:
				Transitioned.emit(self, "landing")
