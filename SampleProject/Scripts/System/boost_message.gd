extends Node2D

@export var sound: PolyphonicAudio

func _ready() -> void:
	sound.play_sound_effect_from_library("levelup")

func pause():
	get_tree().paused = true

func unpause():
	get_tree().paused = false
