extends Node
class_name MenuState
@warning_ignore("unused_signal")
signal Transitioned
var menu: InventoryMenu
@export var animation: AnimationPlayer
@export var default_button: InventoryButton
var sound: PolyphonicMenuAudio

func enter():
	animation.play_backwards("change")
	
func exit():
	animation.play("change")
	
func Update(_delta: float):
	pass
	
func Physics_Update(_delta: float):
	pass
	
func play_sound(sfx_name: String):
	sound.play_sound_effect_from_library(sfx_name)
