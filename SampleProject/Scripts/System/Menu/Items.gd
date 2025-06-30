extends MenuState
class_name InvItems

@export var elements: Control
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
	elements.MainStatsValues.text = ""
	for stat in ["HP", "MP", "SP"]:
		elements.MainStatsValues.text += "%4d" % stats[stat] + "/" + "%4d" % stats["M" + stat] + "\n"
		
	elements.health_bar.value = float(Global.getStat("HP")) / Global.getStat("MHP") * elements.health_bar.max_value
	elements.mana_bar.value = float(Global.getStat("MP")) / Global.getStat("MMP") * elements.mana_bar.max_value
	elements.synergy_bar.value = float(Global.getStat("SP")) / Global.getStat("MSP") * elements.synergy_bar.max_value
