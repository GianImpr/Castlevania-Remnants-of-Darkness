extends State
class_name HectorGuardBreak
@export var recoil_speed: Vector2
@export var ignore_landing: Timer
var can_perfect_guard: bool = false


func enter():
	player.velocity.x = recoil_speed.x * player.facing_position * (-1)
	player.velocity.y = recoil_speed.y
	ignore_landing.start()
	animation.play("guard_break")
	sound.play_sound_effect_from_library("block_break")
	
func exit():
	pass
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_die()
	
	if player.is_on_floor() and ignore_landing.is_stopped():
		Transitioned.emit(self, "hard_landing")
