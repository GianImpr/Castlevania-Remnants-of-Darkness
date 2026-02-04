extends State
class_name EctoplasmDying

@export var explosion_particles: CPUParticles2D
@export var sprite: Sprite2D
const DYING_MODULATE: Color = Color(1,1,1,0.5)
const DYING_MAX_VELOCITY: float = 500
const DYING_DURATION: float = 3
var dying_tween: Tween

func enter():
	sound.play_sound_effect_from_library("dying")
	animation.play("dying")
	explosion_particles.emitting = true
	player.velocity = Vector2.ZERO
	sprite.modulate = DYING_MODULATE
	dying_tween = get_tree().create_tween()
	dying_tween.tween_property(player, "velocity:y", DYING_MAX_VELOCITY, DYING_DURATION)
	dying_tween.finished.connect(player.queue_free)
