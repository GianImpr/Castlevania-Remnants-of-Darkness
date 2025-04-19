extends MenuState
class_name InvSkill

@export var labels: Control
@export var skill_list: GridContainer
var accessed_menu: int

func enter():
	animation.play_backwards("change")
	default_button.grab_focus()
	accessed_menu = 0

func exit():
	animation.play("change")

func Update(delta: float):
	if accessed_menu == 0 and Input.is_action_just_pressed("ui_cancel"):
		Transitioned.emit(self, "menu")
	
func Physics_Update(delta: float):
	pass
