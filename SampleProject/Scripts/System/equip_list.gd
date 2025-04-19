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
var weapon_text: Label
var weapon_icon: TextureRect

func _ready() -> void:
	get_child(0).flat = true
	get_child(0)["theme_override_styles/focus"] = button_glow
	get_child(0).pressed.connect(self.on_button_pressed.bind(get_child(0)))
	get_child(0).focus_entered.connect(self.on_focused.bind(get_child(0)))
	

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
			equipSlots.get_child(equipSlots.button_index).grab_focus()
			state_machine.current_state.accessed_menu = 0
	elif not glow_timer.is_stopped():
		glow_timer.stop()
		
func on_button_pressed(button):
	var current_slot = getCurSlot()
	equipSlots.get_child(equipSlots.button_index).grab_focus()
	sound.play_sound_effect_from_library("confirm")
	if equippingWeapon():
		updateProperties(getEquipFromInventory(button.get_index()-2))
	updateNewStats(getEquipFromInventory(button.get_index()-2), getEquipFromCompendium(getCurSlot()-1, getCurCompendium()), ["STR", "CON", "INT", "RES", "SYN", "LCK", "ATK", "DEF"])
	updateStats(["STR", "CON", "INT", "RES", "SYN", "LCK"], labels.SubStatValues)
	updateStats(["ATK", "DEF"], labels.BattleStatsValues)
	updateWeaponSprite(getEquipFromInventory(button.get_index()-2))
	if button.get_index() == 0:
		if current_slot > 0:
			player.addItem(current_slot, getCurInventory())
		setCurSlot(0)
		equipSlots.get_child(equipSlots.button_index).get_child(0).texture = defaultIcon()
		equipSlots.get_child(equipSlots.button_index).text = "--------"
	else:
		if current_slot > 0:
			player.addItem(current_slot, getCurInventory())
		setCurSlot(getCurInventory()[button.get_index()-2]["id"])
		player.removeItem(getCurSlot(), getCurInventory())
		equipSlots.get_child(equipSlots.button_index).get_child(0).texture = getCurCompendium()[getCurSlot()-1]["icon"]
		equipSlots.get_child(equipSlots.button_index).text = getCurCompendium()[getCurSlot()-1][getCurItemProperty("name")]
	equipSlots.on_focused(equipSlots.get_child(equipSlots.button_index))
	equipSlots.menu.accessed_menu = 0
	
	
func on_focused(button):
	if button.get_index() > 0:
		weapon_icon.texture = getCurCompendium()[getCurInventory()[button.get_index()-2]["id"]-1]["icon"]
		weapon_text.text = getCurCompendium()[getCurInventory()[button.get_index()-2]["id"]-1][getCurItemProperty("description")]
	else:
		weapon_icon.texture = load("res://assets/sprites/Items/Inventory/Inventory_255.png")
		weapon_text.text = ""
		
	var selectedEquip = getEquipFromInventory(button.get_index()-2)
	var currentEquip = getCurEquip()
		
	var subStats: Array[String] = ["STR", "CON", "INT", "RES", "SYN", "LCK"]
	var battleStats: Array[String] = ["ATK", "DEF"]
	compareStats(selectedEquip, currentEquip, subStats, labels.SubArrows, labels.NewSubStats)
	compareStats(selectedEquip, currentEquip, battleStats, labels.BattleArrows, labels.NewBattleStats)

	sound.play_sound_effect_from_library("cursor")
	

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
		button.custom_minimum_size.x = 190
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
func updateList():
	for child in get_children():
		if child.get_name() != "Unequip" and child is InventoryButton:
			children.erase(child)
			child.queue_free()
	for child in qty_list.get_children():
		if child.get_index() > 0:
			child.queue_free()
	weapon_icon.texture = load("res://assets/sprites/Items/Inventory/Inventory_255.png")
	weapon_text.text = ""
	resetLabel(labels.SubArrows)
	resetLabel(labels.NewSubStats)
	resetLabel(labels.BattleArrows)
	resetLabel(labels.NewBattleStats)

func _on_glow_timer_timeout() -> void:
	for child in children:
		button_glow.bg_color = Color(glow_intensity, 0, 0)

func getEquipFromCompendium(index: int, compendium):
	if index >= 0:
		return compendium[index]
	return null

func getEquipFromInventory(index: int):
	if index >= 0 and index < getCurInventory().size():
		return getCurCompendium()[getCurInventory()[index]["id"]-1]
	return null
	
func getCurEquip():
	var slot = getCurSlot()
	if slot > 0:
		return getEquipFromCompendium(slot-1, getCurCompendium())
	return null

func getCurSlot() -> int:
	var slots = ["weapon", "artifact", "relic", "head", "body", "legs", "acc1", "acc2"]
	var slot = slots[equipSlots.button_index]
	return player.equipment[slot]
	
func defaultIcon():
	var slot = equipSlots.button_index
	match slot:
		0:
			return load("res://assets/sprites/Items/Inventory/Inventory_462.png")
		1:
			return load("res://assets/sprites/Items/Inventory/NoArtifact.png")
		2:
			return load("res://assets/sprites/Items/Inventory/NoRelic.png")
		3:
			return load("res://assets/sprites/Items/Inventory/NoHead.png")
		4:
			return load("res://assets/sprites/Items/Inventory/NoBody.png")
		5:
			return load("res://assets/sprites/Items/Inventory/NoFoot.png")
		_:
			return load("res://assets/sprites/Items/Inventory/NoEquip.png")

func setCurSlot(id: int):
	var slots = ["weapon", "artifact", "relic", "head", "body", "legs", "acc1", "acc2"]
	var slot = slots[equipSlots.button_index]
	if id >= 0:
		player.equipment[slot] = id

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
	
func updateNewStats(selectedWeapon, currentWeapon, stats: Array[String]):
	for stat in stats:
		if selectedWeapon and currentWeapon:
			player.Boosts[stat] += selectedWeapon[stat] - currentWeapon[stat]
		elif selectedWeapon:
			player.Boosts[stat] += selectedWeapon[stat]
		elif currentWeapon:
			player.Boosts[stat] -= currentWeapon[stat]
		player.Stats[stat] = player.Bases[stat] + player.Boosts[stat]
		
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

func getCurItemProperty(key: String) -> String:
	var prefixes = ["weapon_", "artifact_", "relic_", "headgear_", "body_", "legs_", "accessory_", "accessory_"]
	return prefixes[equipSlots.button_index] + key

func updateWeaponSprite(weapon) -> void:
	if equipSlots.button_index == 0 and weapon is not Weapon:
		Global.player.sprite.removeWeapon()
		return
	if weapon is not Weapon:
		return
	if not weapon.sprite:
		Global.player.sprite.removeWeapon()
	Global.player.sprite.changeWeapon(weapon.sprite)

func updateProperties(weapon):
	if weapon is Weapon:
		Global.player.can_jump_cancel = weapon.jump_cancel
		Global.player.can_crouch_attack = weapon.crouch_attack
	elif weapon == null:
		Global.player.can_jump_cancel = true
		Global.player.can_crouch_attack = true

func equippingWeapon() -> bool:
	return equipSlots.button_index == 0
