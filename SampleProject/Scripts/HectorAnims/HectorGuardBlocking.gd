extends State
class_name HectorGuardBlocking
@export var recoil_speed: float
var can_perfect_guard: bool = false

func enter():
	player.velocity.x = recoil_speed * player.facing_position * (-1)
	animation.play("guarding", -1, 1.7)
	sound.play_sound_effect_from_library("block")
	
func exit():
	player.is_hurt = false
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_die()
	can_fall(true)
	
	if animation.is_playing():
		player.velocity.x *= 0.9
	else:
		player.velocity.x = 0
		Transitioned.emit(self, "guard")
