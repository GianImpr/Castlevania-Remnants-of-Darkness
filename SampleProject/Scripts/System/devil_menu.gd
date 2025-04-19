extends MenuState
class_name InvDevil

@export var labels: Control
@export var id_name: Label
@export var skill_description: Label
@export var skill_list: DevilButtons
var devil: Faerie

func enter():
	devil = Global.player.innocent_devil
	updateSkillList()
	updateStats()
	animation.play_backwards("change")
	skill_list.setButtons()
	default_button = skill_list.get_child(0)
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
	labels.MainStatsMaxValues.text = "/%3d" % devil.stats.Stats["MHearts"]
	labels.ResourcesValues.text = str(devil.stats.Stats["EXP"]) + "\n"
	labels.ResourcesValues.text += str(devil.stats.expNeededToLvUp()-devil.stats.Stats["EXP"]) + "\n"
	skill_description.text = ""
	
func updateSkillList() -> void:
	for ability in devil.stats.skills:
		var button: InventoryButton = InventoryButton.new()
		button.text = ability.name
		button.icon = ability.icon
		button.flat = true
		button.state_machine = get_parent()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.desired_state = self
		skill_list.add_child(button)

func deleteSkillList() -> void:
	for entry in skill_list.get_children():
		entry.queue_free()
