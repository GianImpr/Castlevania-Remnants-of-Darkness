extends State
class_name KamikazeRavenDying
@export var small_explosion_scene: PackedScene
@export var hot_particles: CPUParticles2D
@export var hitbox_shape: CollisionShape2D
const DELETE_DELAY: float = 1

func enter():
	hitbox_shape.set_deferred("disabled", true)
	player.sprite.visible = false
	hot_particles.one_shot = true
	sound.play_sound_effect_from_library("dying")
	var small_explosion = small_explosion_scene.instantiate()
	MetSys.get_current_room_instance().add_child(small_explosion)
	small_explosion.global_position = player.global_position
	get_tree().create_timer(DELETE_DELAY).timeout.connect(player.queue_free)
