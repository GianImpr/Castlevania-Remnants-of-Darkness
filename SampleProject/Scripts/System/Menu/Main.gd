extends MenuState
class_name InvMenu

@export var elements: Control
@export var id_label: RichTextLabelWithButtons
@export var combine_button: InventoryButton
@export var bestiary_button: InventoryButton

func enter():
	animation.play_backwards("change")
	if last_button == null:
		default_button.grab_focus()
	else:
		last_button.grab_focus()
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
	elements.MainStatsValues.text = ""
	elements.SubStatValues.text = ""
	elements.ExperienceValues.text = ""
	elements.GoldValue.text = ""
	elements.TimeValue.text = Global.player.stats.play_time._to_string()
	
	elements.MainStatsValues.text = "%4d" % Global.getStat("LV") + "\n"
	for stat in ["HP", "MP", "SP"]:
		elements.MainStatsValues.text += "%4d" % Global.getStat(stat) + "/" + "%4d" % Global.getStat("M" + stat) + "\n"
	
	elements.health_bar.value = float(Global.getStat("HP")) / Global.getStat("MHP") * elements.health_bar.max_value
	if Global.player.unlocked_magic:
		elements.mana_bar.value = float(Global.getStat("MP")) / Global.getStat("MMP") * elements.mana_bar.max_value
	else:
		elements.mana_bar.value = 0
	elements.synergy_bar.value = float(Global.getStat("SP")) / Global.getStat("MSP") * elements.synergy_bar.max_value

	
	for stat in ["ATK", "DEF"]:
		elements.SubStatValues.text += str(Global.getStat(stat)) + "\n"
	for stat in Global.getBasicStats():
		elements.SubStatValues.text += str(stat) + "\n"
	
	elements.ExperienceValues.text = str(Global.getStat("EXP")) + "\n"
	elements.ExperienceValues.text += str(Global.player.expNeededToLvUp()-Global.getStat("EXP")) + "\n"
	elements.GoldValue.text += str(Global.getStat("GOLD"))
	
	showButtonWithCondition(default_button, "SUMMON_BUTTON", Global.player.pocket_size > 0)
	showButtonWithCondition(combine_button, "COMBINE_BUTTON", Global.player.stats.findItem(Skill.Skills.BLACKSMITH_CONTRACT, Global.player.stats.skill_inventory))
	showButtonWithCondition(bestiary_button, "BESTIARY_BUTTON", Global.player.stats.findItem(Skill.Skills.TOME_OF_MONSTERS, Global.player.stats.skill_inventory))
		
	# This line will be decommented in a further update, when there are more than one innocent devil
	#default_button.disabled = Global.player.pocket_size == 0
	id_label.visible = Global.player.innocent_devil != null

func showButtonWithCondition(button: InventoryButton, button_name: String, condition: bool):
	if condition:
		button.text = button_name
	else:
		button.text = "? ? ?"
	button.disabled = not condition
