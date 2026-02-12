extends State
class_name FrogDying
@export var explosion_scene: PackedScene
@export var hitbox: CollisionShape2D
const FREE_AFTER_SECONDS: float = 1

func enter():
	player.sprite.visible = false
	sound.play_sound_effect_from_library("noise")
	hitbox.set_deferred("disabled", true)
	get_tree().create_timer(FREE_AFTER_SECONDS, false).timeout.connect(player.queue_free)
	var explosion = explosion_scene.instantiate()
	player.velocity = Vector2.ZERO
	explosion.global_position = player.global_position
	MetSys.get_current_room_instance().add_child(explosion)

func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass
