extends State
class_name HectorGuardPerfect
var can_perfect_guard: bool = true


func enter():
	player.velocity.x = 0
	animation.play("perfect_guarding", -1, 2.8)
	sound.play_sound_effect_from_library("perfect_guard")
	
func exit():
	player.is_hurt = false
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_die()
	can_fall(true)
	
	if not animation.is_playing():
		if Input.is_action_pressed("guard"):
			Transitioned.emit(self, "guard")
		else:
			Transitioned.emit(self, "idle")
