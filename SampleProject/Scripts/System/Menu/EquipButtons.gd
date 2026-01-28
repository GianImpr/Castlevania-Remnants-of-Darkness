extends Menu
class_name EquipButtons
@export var equip_list: GridContainer
@export var slot_type: Label
@export var description: Control
var button_index: int
const EQUIPPED_LABELS = ["EQUIPPED_WEAPON", "EQUIPPED_ARTIFACT", "EQUIPPED_RELIC", "EQUIPPED_HEADGEAR", "EQUIPPED_BODY", "EQUIPPED_LEGS", "EQUIPPED_ACC1", "EQUIPPED_ACC2"]

enum DESCRIPTION_CHILDREN {
	ICON,
	TEXT
}

enum EquipSlots {
	WEAPON,
	ARTIFACT,
	RELIC,
	HEADGEAR,
	BODY,
	LEGS,
	ACC_1,
	ACC_2
}

func _ready() -> void:
	super()
	PickUp.change_equipment = setEquipTextAndIcon
	HectorStats.change_slot_icon = setEquipTextAndIcon

func on_button_pressed(which):
	state_machine.current_state.accessed_menu = 1
	sound.play_sound_effect_from_library("confirm")
	equip_list.get_child(0).grab_focus()
	
func on_focused(which):
	super(which)
	button_index = which.get_index() 
	equip_list.updateList()
	var unequip_button = equip_list.get_child(0)
	setEquippedGearDescription(button_index)
	
	# Knuckles are not complete yet, so disable empty hands for now
	#unequip_button.disabled = which.get_index() == 0
	
	match which.get_index():
		0:
			equip_list.initList(Global.player.stats.weapon_inventory)
			if Global.player.isAttacking():
				description.get_child(1).text = tr("CANNOT_CHANGE_WEAPON_MESSAGE")
		1:
			equip_list.initList(Global.player.stats.artifact_inventory)
		2:
			equip_list.initList(Global.player.stats.relic_inventory)
		3:
			equip_list.initList(Global.player.stats.head_inventory)
		4:
			equip_list.initList(Global.player.stats.body_inventory)
		5:
			equip_list.initList(Global.player.stats.legs_inventory)
		6:
			equip_list.initList(Global.player.stats.acc_inventory)
		7:
			equip_list.initList(Global.player.stats.acc_inventory)
			
func setEquipTextAndIcon(slot: int, text: String, icon: CompressedTexture2D) -> void:
	if slot < 0 or slot > get_child(0).get_child_count()-1:
		return
	#get_child(0).get_child(slot).text = text
	get_child(0).get_child(slot).get_child(0).texture = icon

func setEquipIcons(icon: Array[CompressedTexture2D]):
	for button_i in range(0, get_child(0).get_child_count()):
		get_child(0).get_child(button_i).get_child(0).texture = icon[button_i]
		#button_i += 1
		
func saveEquipIcons() -> Array[CompressedTexture2D]:
	var icon: Array[CompressedTexture2D]
	for button_i in range(0, get_child(0).get_child_count()):
		icon.append(get_child(0).get_child(button_i).get_child(0).texture)
	return icon

func setEquippedGearDescription(index: int) -> void:
	var item_type: int = min(index+1, 7) # Caps at 7 because every slot after 7 is accessory, +1 to skip Item type
	var gear_id: int = Global.player.stats.equipment[Global.player.stats.EQUIPMENT_SLOTS.values()[index]]
	var gear = null
	if gear_id > 0:
		gear = PickUp.getCompendium(item_type)[gear_id-1]
		description.get_child(DESCRIPTION_CHILDREN.ICON).texture = gear.icon
		description.get_child(DESCRIPTION_CHILDREN.TEXT).text = tr(EQUIPPED_LABELS[index]) + "\n    " + tr(gear[PickUp.getItemName(item_type)])
	else:
		description.get_child(DESCRIPTION_CHILDREN.ICON).texture = null
		description.get_child(DESCRIPTION_CHILDREN.TEXT).text = tr(EQUIPPED_LABELS[index]) + "\n    "
