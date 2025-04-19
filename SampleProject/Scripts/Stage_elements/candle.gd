extends RigidBody2D
class_name Candle

@export var sprite: Sprite2D
@export var animation: AnimationPlayer
@export var explosion_scene: PackedScene
@export var coin_scene: PackedScene
@export var heart_scene: PackedScene
@export var sound: PolyphonicAudio
@export var hitbox_iframe: CollisionShape2D

func destroy():
	var explosion = explosion_scene.instantiate()
	get_parent().get_parent().call_deferred("add_child", explosion)
	if Global.player.stats.Stats["MP"] == Global.player.stats.Stats["MMP"] and ((Global.player.innocent_devil != null and Global.player.innocent_devil.stats.Stats["Hearts"] == Global.player.innocent_devil.stats.Stats["MHearts"]) or Global.player.innocent_devil == null):
		var coin = coin_scene.instantiate()
		get_parent().get_parent().call_deferred("add_child", coin)
		coin.global_position = global_position
	else:
		var heart = heart_scene.instantiate()
		get_parent().get_parent().call_deferred("add_child", heart)
		heart.global_position = global_position
	explosion.global_position = global_position
	sound.play_sound_effect_from_library("destroy")
	animation.play("destroy")
	
	
	
