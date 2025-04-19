extends Node
class_name CombatScene
@export var event_ID: int
@export var door1: Node2D
@export var door2: Node2D

func _ready():
	if Global.player.stats.combat_flags[event_ID]:
		queue_free()
	else:
		event()
		
func event():
	_dissolveMusic()
	
func openDoors():
	door1.get_child(0).animation.play("open")
	door2.get_child(0).animation.play("open")
	
func _dissolveMusic():
	var tween = get_tree().create_tween()
	tween.tween_property(Global.music_player, "volume_db", -80, 0.8)
	await tween.finished
	Global.music_player.stop()
	Global.music_player.volume_db = -15
	
func playMusic(track: String):
	Global.music_player.volume_db = -15
	Global.music_player.play_sound_effect_from_library(track)
