extends Menu
class_name SummonButtons

func ready() -> void:
	pass

func on_button_pressed(which):
	sound.play_sound_effect_from_library("confirm")
