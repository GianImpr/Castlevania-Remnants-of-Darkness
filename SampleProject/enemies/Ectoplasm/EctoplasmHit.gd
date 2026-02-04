extends State
class_name EctoplasmHit

func enter():
	player.velocity = Vector2.ZERO
	sound.play_sound_effect_from_library("hit")
	animation.play("hit")
	
func exit():
	pass
	
func Update(_delta: float):
	enemy_can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "flying")
	
func Physics_Update(_delta: float):
	pass
