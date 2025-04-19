extends MenuState
class_name InvEquip

@export var labels: Control
@export var equip_list: GridContainer
var accessed_menu: int

func enter():
	animation.play_backwards("change")
	default_button.grab_focus()
	accessed_menu = 0
	equip_list.player = Global.player.stats
	updateStats(["STR", "CON", "INT", "RES", "SYN", "LCK"], labels.SubStatValues)
	updateStats(["ATK", "DEF"], labels.BattleStatsValues)
	
func exit():
	animation.play("change")
	equip_list.updateList()
	
func Update(delta: float):
	if accessed_menu == 0 and Input.is_action_just_pressed("ui_cancel"):
		Transitioned.emit(self, "menu")
	
func Physics_Update(delta: float):
	pass
	
func updateStats(stats: Array[String], label: Label):
	label.text = ""
	for stat in stats:
		label.text += str(Global.player.stats.Stats[stat]) + "\n"
