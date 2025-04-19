extends Menu
class_name HintButtons

func on_focused(which) -> void:
	menu.on_focused(which)
	
func on_button_pressed(which) -> void:
	menu.on_button_pressed(which)
