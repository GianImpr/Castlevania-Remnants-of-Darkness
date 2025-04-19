extends RigidBody2D
@export var power: int
@export var pickup_flag: int
@export var boost_message: PackedScene
@export var animation: AnimationPlayer
@export var sound: PolyphonicAudio
@export var area: Area2D

func _ready():
	if Global.player.stats.picked_items[pickup_flag]:
		queue_free()
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	var popup = boost_message.instantiate()
	popup.get_child(0).frame = 0
	Global.player.stats.Stats["MHP"] += power
	Global.player.stats.Boosts["HP"] += power
	Global.player.stats.Stats["HP"] = Global.player.stats.Stats["MHP"]
	Global.player.sprite.enable_glow = true
	Global.player.add_child(popup)
	Global.player.stats.picked_items[pickup_flag] = true
	visible = false
	area.set_deferred("monitoring", false)
	sound.play_sound_effect_from_library("life_up")
	await sound.finished
	queue_free()
