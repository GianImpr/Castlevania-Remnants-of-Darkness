extends State
class_name ToadDying
@export var hitbox: CollisionShape2D
@export var particles: CPUParticles2D
@export var tongue_sprite: Sprite2D
const FREE_AFTER_SECONDS: float = 1.5

func enter():
	player.sprite.visible = false
	tongue_sprite.visible = false
	sound.play_sound_effect_from_library("dying")
	hitbox.set_deferred("disabled", true)
	particles.emitting = true
	get_tree().create_timer(FREE_AFTER_SECONDS, false).timeout.connect(player.queue_free)
	player.velocity = Vector2.ZERO

func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass
