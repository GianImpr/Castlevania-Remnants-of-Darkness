extends MenuState
class_name InvItems

@export var elements: Control
@export var item_list: GridContainer
@export var MP_bar: TextureProgressBar
var accessed_menu: int
@export var status_gradients: Array[GradientTexture2D]

enum StatusGradient {
	PETRIFIED,
	POISON,
	CURSE,
	ENFEEBLE,
	GOOD
}

func enter():
	animation.play_backwards("change")
	updateStats()
	default_button.grab_focus()
	accessed_menu = 0
	MP_bar.texture_progress = Global.HUD.mana.texture_progress
	
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
	
	updateStatusLabel()
	elements.health_bar.value = float(Global.getStat("HP")) / Global.getStat("MHP") * elements.health_bar.max_value
	elements.mana_bar.value = float(Global.getStat("MP")) / Global.getStat("MMP") * elements.mana_bar.max_value
	elements.synergy_bar.value = float(Global.getStat("SP")) / Global.getStat("MSP") * elements.synergy_bar.max_value


func updateStatusLabel() -> void:
	if Global.player.isPetrified():
		elements.StatusValue.text = "PETRIFIED_STATUS"
		elements.StatusValue.get_child(0).texture = status_gradients[StatusGradient.PETRIFIED]
	elif Global.player.stats.status[HectorStats.Status.POISON] > 0:
		elements.StatusValue.text = "POISON_STATUS"
		elements.StatusValue.get_child(0).texture = status_gradients[StatusGradient.POISON]
	elif Global.player.stats.status[HectorStats.Status.CURSE] > 0:
		elements.StatusValue.text = "CURSE_STATUS"
		elements.StatusValue.get_child(0).texture = status_gradients[StatusGradient.CURSE]
	elif Global.player.stats.status[HectorStats.Status.ENFEEBLE] > 0:
		elements.StatusValue.text = "ENFEEBLE_STATUS"
		elements.StatusValue.get_child(0).texture = status_gradients[StatusGradient.ENFEEBLE]
	else:
		elements.StatusValue.text = "GOOD_STATUS"
		elements.StatusValue.get_child(0).texture = status_gradients[StatusGradient.GOOD]
