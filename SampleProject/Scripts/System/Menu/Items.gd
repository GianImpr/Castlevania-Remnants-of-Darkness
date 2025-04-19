extends MenuState
class_name InvItems

@export var labels: Control
@export var item_list: GridContainer
var accessed_menu: int

func enter():
	animation.play_backwards("change")
	updateStats()
	default_button.grab_focus()
	accessed_menu = 0
	
func exit():
	animation.play("change")
	
func Update(delta: float):
	if accessed_menu == 0 and Input.is_action_just_pressed("ui_cancel"):
		Transitioned.emit(self, "menu")
	
func Physics_Update(delta: float):
	pass
	
func updateStats():
	var stats = Global.player.stats.Stats
	labels.MainStatsValues.text = ""
	labels.MainStatsMaxValues.text = ""
	for stat in ["HP", "MP", "SP"]:
		labels.MainStatsValues.text += str(stats[stat]) + "\n"
	for stat in ["MHP", "MMP", "MSP"]:
		labels.MainStatsMaxValues.text += str(stats[stat]) + "\n"
