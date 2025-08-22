extends GridContainer
class_name EquipMenu

@export var button_glow: StyleBoxFlat
@export var glow_timer: Timer
@export var sound: PolyphonicMenuAudio
@export var weapons: WeaponCompendium
var min_glow_intensity: float = 0.34
var glow_intensity: float = min_glow_intensity
var max_glow_intensity: float = 0.44
var children: Array[Button]
var increasing_glow: int = 1
var player
@export var equipSlots: Menu
@export var state_machine: MenuStateMachine
@export var weapon_desc: Node
@export var qty_list: GridContainer
@export var labels: Control
@export var quick_weapon_icons: Control
var weapon_text: Label
var weapon_icon: TextureRect
var cur_selected_item = null
static var quick_weapons: Array = [null, null, null, null]

func _ready() -> void:
	get_child(0).flat = true
	get_child(0)["theme_override_styles/focus"] = button_glow
	get_child(0).pressed.connect(self.on_button_pressed.bind(get_child(0)))
	get_child(0).focus_entered.connect(self.on_focused.bind(get_child(0)))
	WeaponWheel.quickWeaponSwap = quickWeaponSwap

func _process(delta: float) -> void:
	if weapon_desc:
		weapon_text = weapon_desc.get_child(1)
		weapon_icon = weapon_desc.get_child(0)
	if state_machine.current_state is InvEquip:
		glow_intensity = glow_intensity + 0.1*delta*increasing_glow
		if glow_intensity >= max_glow_intensity:
			increasing_glow = -1
		elif glow_intensity < min_glow_intensity:
			increasing_glow = 1
		if glow_timer.is_stopped():
			glow_timer.start()
		if Input.is_action_just_pressed("ui_cancel"):
			equipSlots.get_child(0).get_child(equipSlots.button_index).grab_focus()
			state_machine.current_state.accessed_menu = 0
	elif not glow_timer.is_stopped():
		glow_timer.stop()
	
	#Change current quick weapon slot
	if equipSlots.button_index == 0 and equipSlots.menu.accessed_menu == 1 and state_machine.current_state is InvEquip:
		const RSTICK_ACTIONS: Array[String] = ["rstick_up", "next_skill", "rstick_down", "previous_skill"]
		for i in range(0, RSTICK_ACTIONS.size()):
			if Input.is_action_just_pressed(RSTICK_ACTIONS[i]):
				if quick_weapons[i] != cur_selected_item:
					quick_weapons[i] = cur_selected_item
					quick_weapon_icons.get_child(i).texture = cur_selected_item.icon
				else:
					quick_weapons[i] = null
					quick_weapon_icons.get_child(i).texture = null
				sound.play_sound_effect_from_library("confirm")
				break
		
#Equips the selected item by:
#Updating stats
#Updating the item ID of the current equip slot
#Updating the list by adjust the # of items held after swapping equipment
#Going back a layer in the menu
func on_button_pressed(button):
	var current_slot = getCurSlot()
	equipSlots.get_child(0).get_child(equipSlots.button_index).grab_focus()
	sound.play_sound_effect_from_library("confirm")
	if equippingWeapon():
		updateProperties(getEquipFromInventory(button.get_index()-2))
	elif equippingRelic():
		turnOffRelic()
	updateNewStats(getEquipFromInventory(button.get_index()-2), getEquipFromCompendium(getCurSlot()-1, getCurCompendium()), ["STR", "CON", "INT", "RES", "SYN", "LCK", "ATK", "DEF"])
	updateStats(["ATK", "DEF", "STR", "CON", "INT", "RES", "SYN", "LCK"], labels.SubStatValues)
	updateWeaponSprite(getEquipFromInventory(button.get_index()-2))
	if button.get_index() == 0:
		if current_slot > 0:
			player.addItem(current_slot, getCurInventory())
		setCurSlot(0)
		equipSlots.get_child(0).get_child(equipSlots.button_index).get_child(0).texture = defaultIcon()
		#equipSlots.get_child(0).get_child(equipSlots.button_index).text = "--------"
	else:
		if current_slot > 0:
			player.addItem(current_slot, getCurInventory())
		setCurSlot(getCurInventory()[button.get_index()-2]["id"])
		player.removeItem(getCurSlot(), getCurInventory())
		equipSlots.get_child(0).get_child(equipSlots.button_index).get_child(0).texture = getCurCompendium()[getCurSlot()-1]["icon"]
		#equipSlots.get_child(0).get_child(equipSlots.button_index).text = getCurCompendium()[getCurSlot()-1][getCurItemProperty("name")]
	equipSlots.on_focused(equipSlots.get_child(0).get_child(equipSlots.button_index))
	equipSlots.menu.accessed_menu = 0
	

#Retrieves information about the currently highlighted equipment piece
func on_focused(button):
	if button.get_index() > 0:
		cur_selected_item = getCurCompendium()[getCurInventory()[button.get_index()-2]["id"]-1]
		weapon_icon.texture = cur_selected_item["icon"]
		weapon_text.text = cur_selected_item[getCurItemProperty("description")]
	else:
		weapon_icon.texture = load("res://assets/sprites/Items/InventoryIcons/Inventory_255.png")
		weapon_text.text = ""
		
	var selectedEquip = getEquipFromInventory(button.get_index()-2)
	var currentEquip = getCurEquip()
		
	var subStats: Array[String] = ["ATK", "DEF", "STR", "CON", "INT", "RES", "SYN", "LCK"]
	compareStats(selectedEquip, currentEquip, subStats, labels.SubArrows, labels.NewSubStats)

	sound.play_sound_effect_from_library("cursor")
	

#Creates the equip list corresponding to the currently selected slot
func initList(list: Array[Dictionary]):
	for item in list:
		var button = InventoryButton.new()
		var qty_label = Label.new()
		var item_entry = getCurCompendium()[item["id"]-1]
		var item_quantity = item["quantity"]
		var item_icon = item_entry["icon"]
		var item_name = item_entry[getCurItemProperty("name")]
		qty_label.text = "x" + str(item_quantity)
		qty_list.add_child(qty_label)
		button.icon = item_icon
		button.text = item_name
		add_child(button)
		children.append(button)
		button["theme_override_styles/focus"] = button_glow
		button.pressed.connect(self.on_button_pressed.bind(button))
		button.focus_entered.connect(self.on_focused.bind(button))
		button.state_machine = state_machine
		button.desired_state = equipSlots.menu
		button.flat = true
		button.custom_minimum_size.x = 162
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT

#Deletes the list and resets the labels
func updateList():
	for child in get_children():
		if child.get_name() != "Unequip" and child is InventoryButton:
			children.erase(child)
			child.queue_free()
	for child in qty_list.get_children():
		if child.get_index() > 0:
			child.queue_free()
	weapon_icon.texture = load("res://assets/sprites/Items/InventoryIcons/Inventory_255.png")
	weapon_text.text = ""
	resetLabel(labels.SubArrows)
	resetLabel(labels.NewSubStats)

func _on_glow_timer_timeout() -> void:
	for child in children:
		button_glow.bg_color = Color(glow_intensity, 0, 0)

#Retrieves data from the index-th element of a compendium
func getEquipFromCompendium(index: int, compendium):
	if index >= 0:
		return compendium[index]
	return null

#Retrieves data from the index-th element in the player's possessed items list
func getEquipFromInventory(index: int):
	if index >= 0 and index < getCurInventory().size():
		return getCurCompendium()[getCurInventory()[index]["id"]-1]
	return null

#Retrieves data about the currently equipped item
func getCurEquip():
	var slot = getCurSlot()
	if slot > 0:
		return getEquipFromCompendium(slot-1, getCurCompendium())
	return null

#Gets the id of item equipped in the slot corresponding to the type of currently opened list
func getCurSlot() -> int:
	var slots = ["weapon", "artifact", "relic", "head", "body", "legs", "acc1", "acc2"]
	var slot = slots[equipSlots.button_index]
	return player.equipment[slot]

#Empty icon
func defaultIcon():
	return load("res://assets/sprites/Items/InventoryIcons/Inventory_255.png")

#Applies the selected item ID to the player's corresponding equip slot
func setCurSlot(id: int):
	var slots = ["weapon", "artifact", "relic", "head", "body", "legs", "acc1", "acc2"]
	var slot = slots[equipSlots.button_index]
	if id >= 0:
		player.equipment[slot] = id

#Calculates and shows stat differences when selecting an item to equip
func compareStats(selectedEquip, currentEquip, stats: Array[String], arrowLabel: RichTextLabel, statLabel: RichTextLabel):
	var newStatLabel = "[right]"
	var newArrows = ""
	for stat in stats:
		if selectedEquip and currentEquip:
			player.Estimated[stat] = player.Bases[stat] + player.Boosts[stat] - currentEquip[stat] + selectedEquip[stat]
		elif selectedEquip:
			player.Estimated[stat] = player.Bases[stat] + player.Boosts[stat] + selectedEquip[stat]
		elif currentEquip:
			player.Estimated[stat] = player.Bases[stat] + player.Boosts[stat] - currentEquip[stat]
		else:
			player.Estimated[stat] = player.Bases[stat] + player.Boosts[stat]
			
		if player.Estimated[stat] > player.Stats[stat]:
			newStatLabel += "[color=#0070ff]" + str(player.Estimated[stat]) + "[/color]\n"
			newArrows += "[color=#0070ff]↗[/color]\n"
		elif player.Estimated[stat] < player.Stats[stat]:
			newStatLabel += "[color=#ff4000]" + str(player.Estimated[stat]) + "[/color]\n"
			newArrows += "[color=#ff4000]↘[/color]\n"
		else:
			newArrows += "\n"
			newStatLabel += "\n"
	arrowLabel.text = newArrows
	statLabel.text = newStatLabel + "[/right]"

#Updates the new stats
func updateNewStats(selectedWeapon, currentWeapon, stats: Array[String]):
	for stat in stats:
		if selectedWeapon and currentWeapon:
			player.Boosts[stat] += selectedWeapon[stat] - currentWeapon[stat]
		elif selectedWeapon:
			player.Boosts[stat] += selectedWeapon[stat]
		elif currentWeapon:
			player.Boosts[stat] -= currentWeapon[stat]
		player.Stats[stat] = player.Bases[stat] + player.Boosts[stat]

#Updates the labels showing the current stats, but does not update the stats themselves
func updateStats(stats: Array[String], label: Label):
	player = Global.player.stats
	label.text = ""
	for stat in stats:
		label.text += str(player.Stats[stat]) + "\n"

func resetLabel(label: Control):
	label.text = ""
	
func getCurCompendium():
	match equipSlots.button_index:
		0:
			return Global.player.stats.weapon_compendium
		1:
			return Global.player.stats.artifact_compendium
		2:
			return Global.player.stats.relic_compendium
		3:
			return Global.player.stats.headgear_compendium
		4:
			return Global.player.stats.body_compendium
		5:
			return Global.player.stats.legs_compendium
		6:
			return Global.player.stats.accessory_compendium
		7:
			return Global.player.stats.accessory_compendium
		_:
			return []

func getCurInventory() -> Array[Dictionary]:
	var lists = Global.player.stats
	match equipSlots.button_index:
		0:
			return lists.weapon_inventory
		1:
			return lists.artifact_inventory
		2:
			return lists.relic_inventory
		3:
			return lists.head_inventory
		4:
			return lists.body_inventory
		5:
			return lists.legs_inventory
		6:
			return lists.acc_inventory
		7:
			return lists.acc_inventory
		_:
			printerr("Inventory list " + equipSlots.button_index + " not found")
			return []

#Finds the prefix for the item properties
func getCurItemProperty(key: String) -> String:
	var prefixes = ["weapon_", "artifact_", "relic_", "headgear_", "body_", "legs_", "accessory_", "accessory_"]
	return prefixes[equipSlots.button_index] + key

#Updates the weapon scene to the new weapon one
func updateWeaponSprite(weapon, ignore_button_index: bool = false) -> void:
	if (equipSlots.button_index == 0 or ignore_button_index) and weapon is not Weapon:
		Global.player.sprite.removeWeapon()
		return
	if weapon is not Weapon:
		return
	if not weapon.sprite:
		Global.player.sprite.removeWeapon()
	Global.player.sprite.changeWeapon(weapon.sprite)

#Updates if Hector can jump cancel or crouch attack with the new weapon 
func updateProperties(weapon):
	if weapon is Weapon:
		Global.player.can_jump_cancel = weapon.jump_cancel
		Global.player.can_crouch_attack = weapon.crouch_attack
	elif weapon == null:
		Global.player.can_jump_cancel = true
		Global.player.can_crouch_attack = true

#Checks if the player is equipping a weapon
func equippingWeapon() -> bool:
	return equipSlots.button_index == 0

#Checks if the player is equipping a relic
func equippingRelic() -> bool:
	return equipSlots.button_index == 2

#Turns off the current relic in case the player is changing it
func turnOffRelic() -> void:
	Global.player.enabled_magic = false
	Global.player.aura.visible = false

#Used by the WeaponWheel node: allows to quickly swap between four different weapons
func quickWeaponSwap(weapon_position: int) -> void:
	if Global.player == null:
		return

	var new_wpn = quick_weapons[weapon_position]
	player = Global.player.stats
	var current_weapon_id = player.equipment["weapon"]
	var old_weapon = getEquipFromCompendium(current_weapon_id-1, Game.get_singleton().weapon_compendium)
	updateProperties(quick_weapons[weapon_position])
	updateNewStats(quick_weapons[weapon_position], old_weapon, ["STR", "CON", "INT", "RES", "SYN", "LCK", "ATK", "DEF"])
	#updateStats(["ATK", "DEF", "STR", "CON", "INT", "RES", "SYN", "LCK"], labels.SubStatValues)
	updateWeaponSprite(quick_weapons[weapon_position], true)
	if quick_weapons[weapon_position] != null:
		if current_weapon_id > 0:
			player.addItem(current_weapon_id, player.weapon_inventory)
		player.removeItem(player.getItemIndexInCompendium(quick_weapons[weapon_position], Game.get_singleton().weapon_compendium), player.weapon_inventory)
		player.equipment["weapon"] = player.getItemIndexInCompendium(quick_weapons[weapon_position], Game.get_singleton().weapon_compendium)
		equipSlots.get_child(0).get_child(0).get_child(0).texture = quick_weapons[weapon_position].icon
	else:
		if current_weapon_id > 0:
			player.addItem(current_weapon_id, player.weapon_inventory)
		player.equipment["weapon"] = 0
		equipSlots.get_child(0).get_child(0).get_child(0).texture = defaultIcon()

# Used when saving data
static func serializeQuickWeapons() -> Array[int]:
	var serialized_weapons: Array[int] = [0,0,0,0]
	for i in range(0, quick_weapons.size()):
		if quick_weapons[i] != null:
			serialized_weapons[i] = Global.player.stats.getItemIndexInCompendium(quick_weapons[i], Global.player.stats.weapon_compendium)
	return serialized_weapons

# Used when loading data
static func deserializeQuickWeapons(serialized_weapons: Array[int]) -> void:
	for i in range(0, quick_weapons.size()):
		if serialized_weapons[i] > 0:
			quick_weapons[i] = Game.get_singleton().weapon_compendium[serialized_weapons[i]-1]
		else:
			quick_weapons[i] = null
