extends Menu
class_name CombineButtons

@export var item_list: Menu
@export var material_list: VBoxContainer
@export var confirm_animation: AnimationPlayer
@export var confirm_panel_label: Label
@export var confirm_panel_button: Button
@export var craft_icon: TextureRect
@export var craft_text: RichTextLabel

var button_index: int
var item_id_list: Array[int]
var item_to_craft: int
var uses_equipment_slots: int
static var new_craftable_items: bool = false
static var equipItem: Callable

func _ready() -> void:
	super()
	for button in confirm_panel_button.get_parent().get_children():
		(button as Button).focus_entered.connect(func(): sound.play_sound_effect_from_library("cursor"))

func _process(delta: float) -> void:
	if menu.accessed_menu == 1 and Input.is_action_just_pressed("ui_cancel"):
		get_child(button_index).grab_focus()
		updateMaterialList(null)
		menu.accessed_menu = 0
		
	if menu.accessed_menu == 1 and Input.is_action_just_pressed("menu"):
		deleteList()
		updateMaterialList(null)
		menu.accessed_menu = 0
		
	if menu.accessed_menu == 3 and Input.is_action_just_pressed("ui_accept"):
		sound.play_sound_effect_from_library("confirm")
		confirm_animation.play("close_craft")
		verifyNewRecipes()
		menu.accessed_menu = 1
		item_list.get_child(item_to_craft+1).grab_focus()



func on_focused(button):
	super(button)
	deleteList()
	if getListType(button.get_index()) != null:
		initList(button.get_index())

func on_button_pressed(which):
	if item_list.get_child_count() > 0:
		sound.play_sound_effect_from_library("confirm")
		button_index = which.get_index()
		item_list.get_child(1).grab_focus()
		menu.accessed_menu = 1
	else:
		sound.play_sound_effect_from_library("denied")
		
func getListType(index = null):
	var list_indicator = button_index
	if index != null:
		list_indicator = index
	match list_indicator:
		0:
			return Weapon.Type.SWORD
		1:
			return Weapon.Type.GREATSWORD
		2:
			return Weapon.Type.AXE
		3:
			return Weapon.Type.SPEAR
		4:
			return Weapon.Type.FIST
		6:
			return "Headgear"
		7:
			return "Body"
		8:
			return "Legs"
		_:
			return null
		
func on_item_button_pressed(which):
	sound.play_sound_effect_from_library("confirm")
	menu.accessed_menu = 2
	confirm_panel_label.text = tr("CONFIRM_CRAFT_BUTTON")
	if uses_equipment_slots:
		confirm_panel_label.text = tr("EQUIPPED_ITEM_FOR_CRAFTING_WARNING") + "\n" + confirm_panel_label.text
	confirm_animation.play("show")
	sound.play_sound_effect_from_library("popup")
	item_to_craft = which.get_index()-1
	confirm_panel_button.grab_focus()

func on_item_focused(which) -> void:
	sound.play_sound_effect_from_library("cursor")
	updateMaterialList(getItemFromCompendium(item_id_list[which.get_index()-1], getListType()), getListType())

func deleteList() -> void:
	for item in item_list.get_children():
		if item is Button:
			item.queue_free()
		item_id_list.clear()
	for crafting_material in material_list.get_children():
		crafting_material.queue_free()

func initList(index, check_only_new_icons: bool = false) -> void:
	var new_icon: TextureRect = get_child(index).get_child(0)
	var type = getListType(index)
	var new_stuff_to_craft_in_this_list: bool = false
	var item_number: int = 0
	for item in getItemsFromCompendium(type):
		item_number += 1
		checkRecipeStatus(item, type)
		
		if item.recipe_status == Weapon.RecipeStatus.LOCKED or item.recipe_status == Weapon.RecipeStatus.UNAVAILABLE:
			continue
			
		var item_name: String
		
		if type is Weapon.Type:
			if item is not Weapon:
				continue
			if item.type != type:
				continue
		elif type == "Headgear" and item is not Headgear:
			continue
		elif type == "Body" and item is not Body:
			continue
		elif type == "Legs" and item is not Legs:
			continue
			
		if item is Weapon:
			item_name = item.weapon_name
		elif item is Headgear:
			item_name = item.headgear_name
		elif item is Body:
			item_name = item.body_name
		elif item is Legs:
			item_name = item.legs_name
		
		var available_materials: bool = checkMaterials(item, type)
		if item.recipe_status == Weapon.RecipeStatus.UNLOCKED and available_materials:
			new_craftable_items = true
			new_stuff_to_craft_in_this_list = true
			if check_only_new_icons:
				break
			
		if check_only_new_icons:
			continue

		var item_button = InventoryButton.new()
		if item.recipe_status == Weapon.RecipeStatus.REVEALED:
			item_button.text = item_name
		else:
			item_button.text = "??????"
			
		item_button.disabled = not available_materials
			
		item_id_list.append(item_number)
		item_list.add_child(item_button)
		item_list.children.append(item_button)
		item_button.desired_state = menu
		item_button.state_machine = state_machine
		item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		item_button.custom_minimum_size.x = 250
		item_button.custom_minimum_size.y = 32
		item_button.flat = true
		item_button["theme_override_styles/focus"] = item_list.button_glow
		item_button.pressed.connect(self.on_item_button_pressed.bind(item_button))
		item_button.focus_entered.connect(self.on_item_focused.bind(item_button))
		item_button.fitTextInBox()
	new_icon.visible = new_stuff_to_craft_in_this_list
	
func getItemsFromCompendium(type):
	var compendium = getCompendium(type)
	return compendium

func getItemFromCompendium(index: int, type):
	var compendium = getCompendium(type)
	var hector_stats: HectorStats = Global.player.stats
	return hector_stats.searchItemInCompendium(index, compendium)
	
func getInventory(type):
	var inventories: HectorStats = Global.player.stats
	if type is int and (type == Weapon.Type.SWORD or type == Weapon.Type.AXE or type == Weapon.Type.GREATSWORD or type == Weapon.Type.FIST or type == Weapon.Type.SPEAR):
		return inventories.weapon_inventory
	elif type == "Headgear":
		return inventories.head_inventory
	elif type == "Body":
		return inventories.body_inventory
	elif type == "Legs":
		return inventories.legs_inventory

	
func getCompendium(type):
	var compendiums: HectorStats = Global.player.stats
	if type is int and (type == Weapon.Type.SWORD or type == Weapon.Type.AXE or type == Weapon.Type.GREATSWORD or type == Weapon.Type.FIST or type == Weapon.Type.SPEAR):
		return compendiums.weapon_compendium
	elif str(type) == "Headgear":
		return compendiums.headgear_compendium
	elif str(type) == "Body":
		return compendiums.body_compendium
	elif str(type) == "Legs":
		return compendiums.legs_compendium

func checkMaterials(item, type) -> bool:
	var hector_stats: HectorStats = Global.player.stats
	var material_inventory
	var material_compendium
	var uses_equipment: bool = false
	var equipment_slot_to_use: String = ""
	var is_material_equipped: bool = false
	
	for material_item in item.recipe:
		match material_item["inventory"]:
			Weapon.Inventory.weapon:
				material_inventory = hector_stats.weapon_inventory
				material_compendium = hector_stats.weapon_compendium
				equipment_slot_to_use = hector_stats.EQUIPMENT_SLOTS.WEAPON
			Weapon.Inventory.headgear:
				material_inventory = hector_stats.head_inventory
				material_compendium = hector_stats.headgear_compendium
				equipment_slot_to_use = hector_stats.EQUIPMENT_SLOTS.HEADGEAR
			Weapon.Inventory.body:
				material_inventory = hector_stats.body_inventory
				material_compendium = hector_stats.body_compendium
				equipment_slot_to_use = hector_stats.EQUIPMENT_SLOTS.BODY
			Weapon.Inventory.item:
				material_inventory = hector_stats.item_inventory
				material_compendium = hector_stats.item_compendium.Compendium
			Weapon.Inventory.legs:
				material_inventory = hector_stats.legs_inventory
				material_compendium = hector_stats.legs_compendium
				equipment_slot_to_use = hector_stats.EQUIPMENT_SLOTS.LEGS

		if equipment_slot_to_use != "":
			is_material_equipped = hector_stats.itemEquipped(material_item["id"]-1, equipment_slot_to_use)
		
		var copies_held: int = hector_stats.findItem(material_item["id"], material_inventory)
		
		if material_item["quantity"] > copies_held:
			if material_item["quantity"] == copies_held+int(is_material_equipped):
				uses_equipment = true
			else:
				return false
			
	return true

func craftItem(item, type, button_position) -> void:
	var hector_stats: HectorStats = Global.player.stats
	var material_inventory
	var material_compendium
	var item_data = hector_stats.searchItemInCompendium(item, getCompendium(type))
	var equipment_slot: String
	
	for material_item in item_data.recipe:
		match material_item["inventory"]:
			Weapon.Inventory.weapon:
				material_inventory = hector_stats.weapon_inventory
				material_compendium = hector_stats.weapon_compendium
				equipment_slot = hector_stats.EQUIPMENT_SLOTS.WEAPON
			Weapon.Inventory.headgear:
				material_inventory = hector_stats.head_inventory
				material_compendium = hector_stats.headgear_compendium
				equipment_slot = hector_stats.EQUIPMENT_SLOTS.HEADGEAR
			Weapon.Inventory.body:
				material_inventory = hector_stats.body_inventory
				material_compendium = hector_stats.body_compendium
				equipment_slot = hector_stats.EQUIPMENT_SLOTS.BODY
			Weapon.Inventory.item:
				material_inventory = hector_stats.item_inventory
				material_compendium = hector_stats.item_compendium
			Weapon.Inventory.legs:
				material_inventory = hector_stats.legs_inventory
				material_compendium = hector_stats.legs_compendium
				equipment_slot = hector_stats.EQUIPMENT_SLOTS.LEGS

		if not hector_stats.removeItemCopies(material_item["id"], material_item["quantity"], material_inventory, true):
			equipItem.call(equipment_slot, null, material_compendium, material_inventory)
			hector_stats.removeWeaponInWheel(material_item["id"])
	
	var item_inventory = getInventory(type)
	item_data.recipe_status = Weapon.RecipeStatus.REVEALED
	craft_icon.texture = item_data.icon
	
	var item_name: String
	
	if item_data is Weapon:
		item_name = item_data.weapon_name
	elif item_data is Body:
		item_name = item_data.body_name
	elif item_data is Legs:
		item_name = item_data.legs_name
	elif item_data is Headgear:
		item_name = item_data.headgear_name
	
	craft_text.text = tr("PRODUCED_PREFIX_MESSAGE") + " " + "[color=yellow]" + tr(item_name) + "[/color]!"
	hector_stats.addItem(hector_stats.getItemIndexInCompendium(item_data, getCompendium(type)), item_inventory)
	deleteList()
	initList(button_index)


func checkRecipeStatus(item, type):
	if not item.recipe_status == Weapon.RecipeStatus.LOCKED:
		return
		
	if item.recipe_status == Weapon.RecipeStatus.LOCKED and checkMaterials(item, type):
		item.recipe_status = Weapon.RecipeStatus.UNLOCKED

func updateMaterialList(item, type = 0) -> void:
	for crafting_material in material_list.get_children():
		crafting_material.queue_free()
		
	if item == null:
		return
	
	uses_equipment_slots = false
	for material_item in item.recipe:
		var material_entry: HBoxContainer = HBoxContainer.new()
		var material_icon: TextureRect = TextureRect.new()
		var material_name: RichTextLabel = RichTextLabel.new()
		var material_quantity: RichTextLabel = RichTextLabel.new()
		var text_vbox: VBoxContainer = VBoxContainer.new()
		
		material_entry.custom_minimum_size = Vector2(302, 32)
		material_icon.custom_minimum_size = Vector2(32, 32)
		material_name.custom_minimum_size = Vector2(200, 0)
		material_quantity.custom_minimum_size = Vector2(70, 32)
		material_name.autowrap_mode = TextServer.AUTOWRAP_OFF
		material_name.bbcode_enabled = true
		material_name.fit_content = true
		text_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		material_quantity.bbcode_enabled = true
		
		var hector_stats: HectorStats = Global.player.stats
		var material_inventory
		var material_compendium
		var name_property: String
		var possessed_quantity: int = 0
		var equipment_slot_to_use: String = ""
		
		match material_item["inventory"]:
			Weapon.Inventory.weapon:
				material_inventory = hector_stats.weapon_inventory
				material_compendium = hector_stats.weapon_compendium
				name_property = "weapon_name"
				equipment_slot_to_use = hector_stats.EQUIPMENT_SLOTS.WEAPON
			Weapon.Inventory.headgear:
				material_inventory = hector_stats.head_inventory
				material_compendium = hector_stats.headgear_compendium
				name_property = "headgear_name"
				equipment_slot_to_use = hector_stats.EQUIPMENT_SLOTS.HEADGEAR
			Weapon.Inventory.body:
				material_inventory = hector_stats.body_inventory
				material_compendium = hector_stats.body_compendium
				name_property = "body_name"
				equipment_slot_to_use = hector_stats.EQUIPMENT_SLOTS.BODY
			Weapon.Inventory.item:
				material_inventory = hector_stats.item_inventory
				material_compendium = hector_stats.item_compendium.Compendium
				name_property = "item_name"
			Weapon.Inventory.legs:
				material_inventory = hector_stats.legs_inventory
				material_compendium = hector_stats.legs_compendium
				name_property = "legs_name"
				equipment_slot_to_use = hector_stats.EQUIPMENT_SLOTS.LEGS
		var material_data = hector_stats.searchItemInCompendium(material_item["id"], material_compendium)
		possessed_quantity = hector_stats.findItem(material_item["id"], material_inventory)
		if equipment_slot_to_use != "":
			possessed_quantity += int(hector_stats.itemEquipped(material_item["id"]-1, equipment_slot_to_use)) 

		material_icon.texture = material_data.icon
		material_name.text = material_data[name_property]
		material_quantity.text = "[right]" + str(possessed_quantity) + "/" + str(material_item["quantity"]) + "[/right]"
		
		if possessed_quantity < material_item["quantity"]:
			material_name.text = "[color=#FF8080]" + tr(material_name.text) + "[/color]"
			material_quantity.text = "[right][color=#FF8080]" + material_quantity.text + "[/color][/right]"
		elif possessed_quantity == material_item["quantity"] and equipment_slot_to_use != "" and hector_stats.itemEquipped(material_item["id"]-1, equipment_slot_to_use):
			uses_equipment_slots = true
			material_name.text = "[color=#FFBB40]" + tr(material_name.text) + "[/color]"
			material_quantity.text = "[right][color=#FFBB40]" + material_quantity.text + "[/color][/right]"
		
		text_vbox.add_child(material_name)
		material_entry.add_child(material_icon)
		material_entry.add_child(text_vbox)
		material_entry.add_child(material_quantity)
		material_list.add_child(material_entry)
		
		if material_name.get_content_width() > material_name.get_custom_minimum_size().x:
			var new_font_size: int = float(material_name.get_theme_default_font_size())/material_name.get_content_width()*material_name.custom_minimum_size.x
			var new_font_size_multiplier: float = 1.0
			material_name.add_theme_font_size_override("normal_font_size", new_font_size*new_font_size_multiplier)



func _on_yes_pressed() -> void:
	if not confirm_animation.is_playing():
		confirm_panel_button.release_focus()
		confirm_animation.play_backwards("show")
		sound.play_sound_effect_from_library("confirm")
		await confirm_animation.animation_finished
		updateMaterialList(null)
		craftItem(item_id_list[item_to_craft], getListType(), item_to_craft)
		confirm_animation.play("craft")
		sound.play_sound_effect_from_library("combine")
		await confirm_animation.animation_finished
		menu.accessed_menu = 3

func _on_no_pressed() -> void:
	if not confirm_animation.is_playing():
		confirm_animation.play_backwards("show")
		sound.play_sound_effect_from_library("confirm")
		await confirm_animation.animation_finished
		updateMaterialList(null)
		item_list.get_child(item_to_craft+1).grab_focus()
		menu.accessed_menu = 1

func verifyNewRecipes() -> void:
	for index in range(0, get_child_count()):
		if index == 5:
			continue
		initList(index, true)
