extends State
class_name BonePillarDying
@export var dying_scene: PackedScene

func enter():
	sound.volume_db = -15
	sound.play_sound_effect_from_library("dead")
	animation.play("dying", -1, 1)
	var dying_bone = dying_scene.instantiate()
	dying_bone.global_position = player.global_position
	for node in dying_bone.get_children():
		if node is RigidBody2D:
			node.get_child(0).scale.x *= player.facing_position * (-1)
	get_parent().get_parent().get_parent().add_child(dying_bone)
