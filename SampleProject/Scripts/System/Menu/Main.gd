extends MenuState
class_name InvMenu

@export var labels: Control
@export var id_label: RichTextLabelWithButtons

func enter():
	animation.play_backwards("change")
	default_button.grab_focus()
	updateStats()
	
func Update(delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		Transitioned.emit(self, "closed")
	if Input.is_action_just_pressed("guard") and Global.player.innocent_devil != null:
		Transitioned.emit(self, "devil")
		animation.play("change")
	
func Physics_Update(delta: float):
	pass
		
func updateStats():
	labels.LevelValue.text = str(Global.getStat("LV"))
	labels.LevelValue.text = ""
	labels.MainStatsValues.text = ""
	labels.MainStatsMaxValues.text = ""
	labels.SubStatValues.text = ""
	labels.BattleStatsValues.text = ""
	labels.TimeValue.text = Global.player.stats.play_time._to_string()
	labels.LevelValue.text = str(Global.getStat("LV"))
	for stat in Global.getBasicStats():
		labels.SubStatValues.text += str(stat) + "\n"
	for stat in ["HP", "MP", "SP"]:
		labels.MainStatsValues.text += str(Global.getStat(stat)) + "\n"
		labels.MainStatsMaxValues.text += str(Global.getStat("M" + stat)) + "\n"
	for stat in ["ATK", "DEF"]:
		labels.BattleStatsValues.text += str(Global.getStat(stat)) + "\n"
	labels.ResourcesValues.text = str(Global.getStat("EXP")) + "\n"
	labels.ResourcesValues.text += str(Global.player.expNeededToLvUp()-Global.getStat("EXP")) + "\n"
	labels.ResourcesValues.text += str(Global.getStat("GOLD")) + "\n"
	if Global.player.pocket_size > 0:
		default_button.text = "Summon"
	else:
		default_button.text = "? ? ?"
	default_button.disabled = true
	# This line will be decommented in a further update, when there are more than one innocent devil
	#default_button.disabled = Global.player.pocket_size == 0
	id_label.visible = Global.player.innocent_devil != null
