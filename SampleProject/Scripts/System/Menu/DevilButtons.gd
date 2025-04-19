extends Menu
class_name DevilButtons
@export var skill_description: Label

func ready() -> void:
	pass
	
func on_focused(which):
	sound.play_sound_effect_from_library("cursor")
	skill_description.text = Global.player.innocent_devil.stats.skills[which.get_index()].description

func on_button_pressed(which):
	sound.play_sound_effect_from_library("denied")
