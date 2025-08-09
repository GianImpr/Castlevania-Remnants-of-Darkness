extends Node2D

@export var sound: PolyphonicAudio

func _ready() -> void:
	sound.play_sound_effect_from_library("levelup")

func pause():
	if Global.screen == Global.ScreenType.NONE:
		Global.screen = Global.ScreenType.EVENT
		get_tree().paused = true

func unpause():
	if Global.screen == Global.ScreenType.EVENT:
		Global.screen = Global.ScreenType.NONE
		get_tree().paused = false
