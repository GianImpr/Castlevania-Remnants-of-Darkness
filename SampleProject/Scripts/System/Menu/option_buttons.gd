extends Menu
class_name OptionButtons

@export var description: Node
	
func on_focused(button):
	sound.play_sound_effect_from_library("cursor")
	
func on_button_pressed(which):
	sound.play_sound_effect_from_library("confirm")
	menu.inner_menu = which.get_index()
	menu.menus[menu.inner_menu].visible = true
	var but = menu.menus[menu.inner_menu].get_child(0).get_child(0)
	menu.menus[menu.inner_menu].get_child(0).get_child(0).grab_focus() #Gets the first button in the Options VBoxContainer


func updateDescription() -> void:
	pass
