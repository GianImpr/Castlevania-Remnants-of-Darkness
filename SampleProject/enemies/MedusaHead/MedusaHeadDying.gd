extends State
class_name MedusaHeadDying
@export var hitbox_shape: CollisionShape2D
@export var explosion_scene: PackedScene
const DELETE_DELAY: float = 1

func enter():
	player.blood_particles.emitting = true
	player.velocity = Vector2(0, 0)
	player.sprite.visible = false
	hitbox_shape.set_deferred("disabled", true)
	var explosion = explosion_scene.instantiate()
	explosion.global_position = player.global_position
	MetSys.get_current_room_instance().add_child(explosion)
	get_tree().create_timer(DELETE_DELAY).timeout.connect(player.queue_free)
