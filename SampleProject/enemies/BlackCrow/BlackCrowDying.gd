extends State
class_name BlackCrowDying
@export var explosion_scene: PackedScene
@export var DESCENDING_SPEED: float

func enter():
	player.velocity = Vector2(0, DESCENDING_SPEED)
	animation.play("dead")
	sound.play_sound_effect_from_library("die")

func explode():
	var explosion = explosion_scene.instantiate()
	MetSys.get_current_room_instance().call_deferred("add_child", explosion)
	explosion.global_position = player.global_position
