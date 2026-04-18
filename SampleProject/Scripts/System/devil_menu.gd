extends MenuState
class_name InvDevil

@export var labels: Control
@export var id_name: Label
@export var skill_description: Label
@export var skill_list: DevilButtons
@export var evo_crystals: HBoxContainer
var devil: InnocentDevil

func enter():
	devil = Global.player.innocent_devil
	updateSkillList()
	updateStats()
	animation.play_backwards("change")
	skill_list.setButtons()
	default_button = skill_list.get_child(0).get_child(0)
	default_button.grab_focus()
	
func exit():
	animation.play("change")
	deleteSkillList()
	
func Update(delta: float):
	if Input.is_action_just_pressed("backdash"):
		Transitioned.emit(self, "menu")
		animation.play("change")
	
func Physics_Update(delta: float):
	pass
		
func updateStats():
	id_name.text = devil.id_name
	labels.StatusValue.text = ""
	for stat in ["LV", "Hearts", "ATK", "DEF", "INT", "MND"]:
		labels.StatusValue.text += str(devil.stats.Stats[stat]) + "\n"
	labels.SubStatValues.text = "/%3d" % devil.stats.Stats["MHearts"]
	labels.ExperienceValues.text = str(devil.stats.Stats["EXP"]) + "\n"
	labels.ExperienceValues.text += str(devil.stats.expNeededToLvUp()-devil.stats.Stats["EXP"]) + "\n"
	skill_description.text = ""
	for i in range(1,9,2):
		evo_crystals.get_child(i).text = str(devil.stats.evo_crystals[i/2])

	
func updateSkillList() -> void:
	const SKILL_PANEL_MINIMUM_SIZE: Vector2 = Vector2(500, 40)
	const SKILL_BUTTON_MINIMUM_SIZE: Vector2 = Vector2(400, 40)
	const SKILL_COST_MINIMUM_SIZE: Vector2 = Vector2(50, 0)
	const BUTTON_FOCUSED_COLOR: Color = Color(1, 0.733, 0)
	for ability: IDSkill in devil.stats.skills:
		if not ability.unlocked:
			continue
			
		var skill_panel: HBoxContainer = HBoxContainer.new()
		skill_panel.custom_minimum_size = SKILL_PANEL_MINIMUM_SIZE
		
		var button: InventoryButton = InventoryButton.new()
		button.custom_minimum_size = SKILL_BUTTON_MINIMUM_SIZE
		button.text = ability.name
		button.icon = ability.icon
		button.flat = true
		button.add_theme_color_override("font_focus_color", BUTTON_FOCUSED_COLOR)
		button.state_machine = get_parent()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.desired_state = self
		
		var cost: Label = Label.new()
		cost.custom_minimum_size = SKILL_COST_MINIMUM_SIZE
		cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cost.text = str(ability.cost)
		
		skill_panel.add_child(button)
		skill_panel.add_child(cost)
		skill_list.add_child(skill_panel)

func deleteSkillList() -> void:
	for entry in skill_list.get_children():
		entry.queue_free()
