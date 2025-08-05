extends State
class_name CtulhuDying
@export var explosion_sound_repeat_timer: Timer
const TOTAL_EXPLOSION_SOUNDS: int = 25
var explosion_sounds_played: int = 0

func enter():
	explosion_sounds_played = 0
	explosion_sound_repeat_timer.start()
	sound.play_sound_effect_from_library("dying")
	sound.play_sound_effect_from_library("dying_explosion")
	explosion_sound_repeat_timer.timeout.connect(playExplosionSound)
	player.flying = false
	player.velocity = Vector2(0, 0)
	animation.play("dying")
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass

func playExplosionSound() -> void:
	sound.play_sound_effect_from_library("dying_explosion")
	explosion_sounds_played += 1
	if explosion_sounds_played == TOTAL_EXPLOSION_SOUNDS:
		explosion_sound_repeat_timer.stop()
