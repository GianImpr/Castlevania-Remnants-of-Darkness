extends RigidBody2D
class_name Canister

@export var animation: AnimationPlayer
@export var item_scene: PackedScene
@export var pickup_flag: int
@export var sound: PolyphonicAudio
@export var hitbox_iframe: CollisionShape2D
@export var type: PickUp.ItemType
@export var id: int

func destroy():
	var item = item_scene.instantiate()
	item.pickup_flag = pickup_flag
	get_parent().get_parent().call_deferred("add_child", item)
	item.global_position = global_position
	item.global_position.y -= 15
	if item is PickUp:
		item.type = type
		item.id = id
	sound.play_sound_effect_from_library("canister")
	animation.play("destroy")
