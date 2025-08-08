extends MenuState
class_name InvEquip

@export var labels: Control
@export var equip_list: EquipMenu
var accessed_menu: int

func enter():
	animation.play_backwards("change")
	default_button.grab_focus()
	accessed_menu = 0
	equip_list.player = Global.player.stats
	default_button.disabled = Global.player.isAttacking()
	updateStats(["ATK", "DEF", "STR", "CON", "INT", "RES", "SYN", "LCK"], labels.SubStatValues)
	updateQuickWeaponIcons()
	
func exit():
	animation.play("change")
	equip_list.updateList()
	
func Update(delta: float):
	if accessed_menu == 0 and Input.is_action_just_pressed("ui_cancel"):
		Transitioned.emit(self, "menu")
	
func Physics_Update(delta: float):
	pass
	
func updateStats(stats: Array[String], label: Label) -> void:
	label.text = ""
	for stat in stats:
		label.text += str(Global.player.stats.Stats[stat]) + "\n"

func updateQuickWeaponIcons() -> void:
	var quick_weapons_icons: Control = equip_list.quick_weapon_icons
	for i in range(0, EquipMenu.quick_weapons.size()):
		if EquipMenu.quick_weapons[i] != null:
			quick_weapons_icons.get_child(i).texture = EquipMenu.quick_weapons[i].icon
