extends Menu
class_name MenuButtons

func on_button_pressed(which):
	match which.get_index():
		0:
			menu.Transitioned.emit(menu, "summons")
		1:
			menu.Transitioned.emit(menu, "items")
		2:
			menu.Transitioned.emit(menu, "equip")
		5:
			menu.Transitioned.emit(menu, "hints")
		6:
			menu.Transitioned.emit(menu, "skills")
		7:
			menu.Transitioned.emit(menu, "options")
	sound.play_sound_effect_from_library("confirm")
