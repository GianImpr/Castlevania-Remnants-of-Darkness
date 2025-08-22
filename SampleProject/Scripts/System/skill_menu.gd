extends MenuState
class_name InvSkill

@export var labels: Control
@export var skill_list: GridContainer
@export var skill_proficiency: HBoxContainer
var accessed_menu: int

func enter():
	animation.play_backwards("change")
	default_button.grab_focus()
	accessed_menu = 0
	updateStats()

func exit():
	animation.play("change")

func Update(delta: float):
	if accessed_menu == 0 and Input.is_action_just_pressed("ui_cancel"):
		Transitioned.emit(self, "menu")
	
func Physics_Update(delta: float):
	pass
	
func updateStats() -> void:
	var levels: Array[String] = ["E", "D", "C", "B", "A", "S"]
	for i in range(0, skill_proficiency.get_child_count()):
		var category: Control = skill_proficiency.get_child(i)
		var level_label: Label = category.get_child(1)
		var experience_bar: TextureProgressBar = category.get_child(0).get_child(0)
		var cur_weapon_lv: int = Global.player.stats.weapon_proficiency[i]["lv"]
		var cur_weapon_exp: int = Global.player.stats.weapon_proficiency[i]["exp"]
		var total_exp_for_next_lv: int = 150*((cur_weapon_lv+1)*1.5)*log((cur_weapon_lv+1)*1.5+2.7)
		var minimum_exp_for_cur_lv: int = 150*(cur_weapon_lv*1.5)*log(cur_weapon_lv*1.5+2.7)
		level_label.text = levels[cur_weapon_lv]
		if cur_weapon_lv < Global.player.MAX_WEAPON_RANK:
			experience_bar.value = cur_weapon_exp-minimum_exp_for_cur_lv
			experience_bar.max_value = total_exp_for_next_lv-minimum_exp_for_cur_lv
		else:
			experience_bar.value = experience_bar.max_value
