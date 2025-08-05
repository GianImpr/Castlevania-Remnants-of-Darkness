extends State
class_name FloatingSkullDying

func enter():
	player.velocity = Vector2(0, 0)
	animation.play("dying")
	sound.play_sound_effect_from_library("dying")
