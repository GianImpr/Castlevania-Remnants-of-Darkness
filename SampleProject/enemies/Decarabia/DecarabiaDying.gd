extends State
class_name DecarabiaDying
const SPEED: float = 60
@export var sound_interval_timer: Timer
const STOP_SOUND_AFTER_SECONDS: float = 2.9

func enter():
	if not sound_interval_timer.timeout.is_connected(sound.play_sound_effect_from_library):
		sound_interval_timer.timeout.connect(sound.play_sound_effect_from_library.bind("bubble"))
	
	sound_interval_timer.start()
	sound.play_sound_effect_from_library("bubble")
	player.velocity.x = SPEED*player.facing_position
	animation.play("dying")
	
func exit():
	pass

func Update(delta: float):
	if animation.current_animation_position >= STOP_SOUND_AFTER_SECONDS and not sound_interval_timer.is_stopped():
		sound_interval_timer.stop()

func Physics_Update(delta: float):
	pass
