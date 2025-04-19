extends Menu
class_name EquipButtons
@export var equip_list: GridContainer
@export var slot_type: Label
var button_index: int

func _ready() -> void:
	super()
	PickUp.change_equipment = setEquipTextAndIcon

func on_button_pressed(which):
	state_machine.current_state.accessed_menu = 1
	sound.play_sound_effect_from_library("confirm")
	equip_list.get_child(0).grab_focus()
	
func on_focused(which):
	sound.play_sound_effect_from_library("cursor")
	if which.get_index() < 6:
		slot_type.text = which.get_name()
	else:
		slot_type.text = "Accessory"
	button_index = which.get_index() 
	equip_list.updateList()
	var unequip_button = equip_list.get_child(0)
	
	# Knuckles are not complete yet, so disable empty hands for now
	unequip_button.disabled = which.get_index() == 0
	
	match which.get_index():
		0:
			equip_list.initList(Global.player.stats.weapon_inventory)
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
	if slot < 0 or slot > get_child_count()-1:
		return
	get_child(slot).text = text
	get_child(slot).get_child(0).texture = icon

func setEquipTextAndIcons(text: Array[String], icon: Array[CompressedTexture2D]):
	for button_i in range(0, get_child_count()):
		get_child(button_i).text = text[button_i]
		get_child(button_i).get_child(0).texture = icon[button_i]
		#button_i += 1

func saveEquipText() -> Array[String]:
	var text: Array[String]
	for button_i in range(0, get_child_count()):
		text.append(get_child(button_i).text)
	return text
	
func saveEquipIcons() -> Array[CompressedTexture2D]:
	var icon: Array[CompressedTexture2D]
	for button_i in range(0, get_child_count()):
		icon.append(get_child(button_i).get_child(0).texture)
	return icon
	
