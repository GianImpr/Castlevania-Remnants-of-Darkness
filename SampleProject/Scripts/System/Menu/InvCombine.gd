extends MenuState
class_name InvCombine

@export var item_list: Menu
var accessed_menu: int

func enter():
	animation.play_backwards("change")
	default_button.grab_focus()
	accessed_menu = 0

func exit():
	animation.play("change")
	item_list.confirm_animation.play("RESET")

func Update(delta: float):
	if accessed_menu == 0 and Input.is_action_just_pressed("ui_cancel"):
		Transitioned.emit(self, "menu")
	
func Physics_Update(delta: float):
	pass
