extends Menu
class_name ItemButtons

@export var item_list: GridContainer
@export var qty_list: GridContainer
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
	labels.ResourcesValues.text = ""
	sound.play_sound_effect_from_library("cursor")
	deleteList()
	match button.get_index():
		0:
			initList(1)
		1:
			initList(0)
		2:
			initList(2)
		3:
			initList(3)

func on_button_pressed(which):
	if item_list.get_child_count() > 0:
		sound.play_sound_effect_from_library("confirm")
		button_index = which.get_index()
		item_list.get_child(0).grab_focus()
		menu.accessed_menu = 1
	else:
		sound.play_sound_effect_from_library("denied")
		
func getListType():
	match button_index:
		0:
			return 1
		1:
			return 0
		2:
			return 2
		3:
			return 3
		
func on_item_button_pressed(which):
	var item_to_be_used = getItemFromInventory(which.get_index(), getListType())
	if not useItem(item_to_be_used):
		return
	if Global.player.stats.item_inventory[getItemIndex(which.get_index(), item_to_be_used.type)]["quantity"] == 1:
		which.queue_free()
		qty_list.get_child(which.get_index()).queue_free()
		updateDescription(null)
		if item_list.get_child_count() != 1:
			if item_list.get_child(which.get_index()+1):
				item_list.get_child(which.get_index()+1).grab_focus()
			elif item_list.get_child(which.get_index()-1):
				item_list.get_child(which.get_index()-1).grab_focus()
	else:
		qty_list.get_child(which.get_index()).text = "x" + str(Global.player.stats.item_inventory[getItemIndex(which.get_index(), item_to_be_used.type)]["quantity"]-1)
	Global.player.stats.removeItem(Global.player.stats.getItemIndexInCompendium(getItemFromInventory(which.get_index(), getListType()), Global.player.stats.item_compendium.Compendium), Global.player.stats.item_inventory)
	
func on_item_focused(which) -> void:
	sound.play_sound_effect_from_library("cursor")
	updateDescription(getItemFromInventory(which.get_index(), getListType()))
	displayProperties(getItemFromInventory(which.get_index(), getListType()))

func deleteList() -> void:
	for item in item_list.get_children():
		item.queue_free()
	for label in qty_list.get_children():
		label.queue_free()

func initList(itemType: int) -> void:
	for slot in Global.player.stats.item_inventory:
		var item = getItemFromCompendium(slot["id"])
		if item.type == itemType:
			var item_button = InventoryButton.new()
			if itemType == item.Type.CONSUMABLE:
				var qty_label = Label.new()
				qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				qty_label.text = "x" + str(slot["quantity"])
				qty_list.add_child(qty_label)
			item_button.text = item["item_name"]
			item_button.icon = item["icon"]
			item_list.add_child(item_button)
			item_list.children.append(item_button)
			item_button.desired_state = menu
			item_button.state_machine = state_machine
			item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			item_button.custom_minimum_size.x = 192
			item_button.flat = true
			item_button["theme_override_styles/focus"] = item_list.button_glow
			item_button.pressed.connect(self.on_item_button_pressed.bind(item_button))
			item_button.focus_entered.connect(self.on_item_focused.bind(item_button))
	
func getItemFromCompendium(index: int) -> Item:
	var item_compendium = Global.player.stats.item_compendium.Compendium
	if index > 0:
		return item_compendium[index-1]
	return null

func getItemFromInventory(index: int, type: int) -> Item:
	var item_compendium = Global.player.stats.item_compendium.Compendium
	var inventory = Global.player.stats.item_inventory
	var slot = -1
	var item_slot: Dictionary
	for item in inventory:
		if getItemFromCompendium(item["id"])["type"] == type:
			slot += 1
		if slot == index:
			item_slot = item
			break
	if slot >= 0:
		return getItemFromCompendium(item_slot["id"])
	return null
	
func getItemIndex(index: int, type: int) -> int:
	var item_compendium = Global.player.stats.item_compendium.Compendium
	var inventory = Global.player.stats.item_inventory
	var slot = -1
	var cur_index = 0
	var item_slot: Dictionary
	for item in inventory:
		if getItemFromCompendium(item["id"])["type"] == type:
			slot += 1
		if slot == index:
			item_slot = item
			break
		cur_index += 1
	if slot >= 0:
		return cur_index
	return -1
	
func updateDescription(item: Item) -> void:
	var item_icon = description.get_child(0)
	var item_text = description.get_child(1)
	if item:
		item_icon.texture = item["icon"]
		item_text.text = item["item_description"]
	else:
		item_icon.texture = null
		item_text.text = ""

func useItem(item: Item) -> bool:
	if item.type != item.Type.CONSUMABLE:
		sound.play_sound_effect_from_library("denied")
		return false
	var stats = Global.player.stats.Stats 
	match item.healing_type:
		item.HealingType.HEALTH:
			stats["HP"] = min(stats["HP"]+item.power, stats["MHP"])
			sound.play_sound_effect_from_library("HPItem")
		item.HealingType.MAGIC:
			stats["MP"] = min(stats["MP"]+item.power, stats["MMP"])
			sound.play_sound_effect_from_library("MPItem")
		item.HealingType.SYNERGY:
			stats["SP"] = min(stats["SP"]+item.power, stats["MSP"])
	menu.updateStats()
	return true
	
	#Global.player.stats.removeItem()
func displayProperties(item: Item) -> void:
	labels.ResourcesValues.text = ""
	if item.power == 0:
		return
	match item.healing_type:
		item.HealingType.HEALTH:
			labels.ResourcesValues.text += "HP "
		item.HealingType.MAGIC:
			labels.ResourcesValues.text += "MP "
		item.HealingType.SYNERGY:
			labels.ResourcesValues.text += "SP "
	if item.power > 0:
		labels.ResourcesValues.text += "+" + str(item.power)
	else:
		labels.ResourcesValues.text += "-" + str(item.power)
