extends Menu
class_name SkillButtons

@export var skill_list: GridContainer
@export var cost_list: GridContainer
@export var description: Node
@export var labels: Control
var button_index: int

func _process(delta: float) -> void:
	if menu.accessed_menu == 1 and Input.is_action_just_pressed("ui_cancel"):
		get_child(button_index).grab_focus()
		updateDescription(null)
		menu.accessed_menu = 0
		
	if menu.accessed_menu == 1 and Input.is_action_just_pressed("menu"):
		deleteList()
		updateDescription(null)
		menu.accessed_menu = 0

func on_focused(button):
	sound.play_sound_effect_from_library("cursor")
	deleteList()
	match button.get_index():
		0:
			initList(0)
		1:
			pass
		2:
			pass
		3:
			pass

func on_button_pressed(which):
	if skill_list.get_child_count() > 0:
		sound.play_sound_effect_from_library("confirm")
		button_index = which.get_index()
		skill_list.get_child(0).grab_focus()
		menu.accessed_menu = 1
	else:
		sound.play_sound_effect_from_library("denied")
		
func getListType():
	match button_index:
		0:
			return 0
		1:
			pass
		2:
			pass
		3:
			pass
		
func on_skill_button_pressed(which):
	sound.play_sound_effect_from_library("denied")

func on_skill_focused(which) -> void:
	sound.play_sound_effect_from_library("cursor")
	updateDescription(getSkillFromInventory(which.get_index(), getListType()))

func deleteList() -> void:
	for skill in skill_list.get_children():
		skill.queue_free()
	for label in cost_list.get_children():
		label.queue_free()

func initList(skillType: int) -> void:
	for slot in Global.player.stats.skill_inventory:
		var skill = getSkillFromCompendium(slot["id"])
		if skill.type == skillType:
			var skill_button = InventoryButton.new()
			if skillType == skill.SkillType.PICKABLE:
				var cost_label = Label.new()
				cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				if skill.cost_value > 0:
					cost_label.text = "" + str(skill.cost_value) + " " + str(Skill.CostType.keys()[skill.cost_type])
				else:
					cost_label.text = ""
				cost_list.add_child(cost_label)
			skill_button.text = skill["skill_name"]
			skill_button.icon = skill["icon"]
			skill_list.add_child(skill_button)
			skill_list.children.append(skill_button)
			skill_button.desired_state = menu
			skill_button.state_machine = state_machine
			skill_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			skill_button.custom_minimum_size.x = 192
			skill_button.flat = true
			skill_button["theme_override_styles/focus"] = skill_list.button_glow
			skill_button.pressed.connect(self.on_skill_button_pressed.bind(skill_button))
			skill_button.focus_entered.connect(self.on_skill_focused.bind(skill_button))
	
func getSkillFromCompendium(index: int) -> Skill:
	var item_compendium = Global.player.stats.skill_compendium
	if index > 0:
		return item_compendium[index-1]
	return null

func getSkillFromInventory(index: int, type: int) -> Skill:
	var item_compendium = Global.player.stats.skill_compendium
	var inventory = Global.player.stats.skill_inventory
	var slot = -1
	var skill_slot: Dictionary
	for skill in inventory:
		if getSkillFromCompendium(skill["id"])["type"] == type:
			slot += 1
		if slot == index:
			skill_slot = skill
			break
	if slot >= 0:
		return getSkillFromCompendium(skill_slot["id"])
	return null
	
func updateDescription(skill: Skill) -> void:
	var skill_icon = description.get_child(0)
	var skill_text = description.get_child(1)
	skill_text.controller_scheme = Global.game.controller_scheme
	if skill:
		skill_icon.texture = skill["icon"]
		skill_text.new_text = skill["skill_description"]
	else:
		skill_icon.texture = null
		skill_text.new_text = ""
