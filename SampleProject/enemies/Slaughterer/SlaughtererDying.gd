extends State
class_name SlaughtererDying
@export var explosion_sound_timer: Timer
const EXPLOSION_SOUNDS: int = 14
var cur_explosions_left: int

func _ready() -> void:
	explosion_sound_timer.timeout.connect(explosionSound)

func enter():
	player.velocity.x = 0
	sound.play_sound_effect_from_library("explosion")
	cur_explosions_left = EXPLOSION_SOUNDS
	animation.play("dying")
	explosion_sound_timer.start()
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		animation.play("dying")

func Physics_Update(delta: float):
	pass
	
func explosionSound() -> void:
	sound.play_sound_effect_from_library("explosion")
	cur_explosions_left -= 1
	if cur_explosions_left == 0:
		explosion_sound_timer.stop()
	
