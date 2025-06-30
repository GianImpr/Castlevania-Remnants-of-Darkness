extends Menu
class_name CombineButtons

@export var item_list: Menu
@export var material_list: VBoxContainer
@export var description: Node
@export var confirm_animation: AnimationPlayer
@export var confirm_panel_button: Button
@export var craft_icon: TextureRect
@export var craft_text: RichTextLabel

var button_index: int
var item_id_list: Array[int]
var item_to_craft: int

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
		menu.accessed_menu = 1
		item_list.get_child(item_to_craft).grab_focus()



func on_focused(button):
	super(button)
	deleteList()
	if getListType(button.get_index()) != null:
		initList(button.get_index())

func on_button_pressed(which):
	if item_list.get_child_count() > 0:
		sound.play_sound_effect_from_library("confirm")
		button_index = which.get_index()
		item_list.get_child(0).grab_focus()
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
		2:
			return Weapon.Type.AXE
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
	confirm_animation.play("show")
	sound.play_sound_effect_from_library("popup")
	item_to_craft = which.get_index()
	confirm_panel_button.grab_focus()

func on_item_focused(which) -> void:
	sound.play_sound_effect_from_library("cursor")
	updateMaterialList(getItemFromCompendium(item_id_list[which.get_index()], getListType()), getListType())

func deleteList() -> void:
	for item in item_list.get_children():
		item.queue_free()
		item_id_list.clear()
	for crafting_material in material_list.get_children():
		crafting_material.queue_free()

func initList(index) -> void:
	var type = getListType(index)
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
		
		var item_button = InventoryButton.new()
		if item.recipe_status == Weapon.RecipeStatus.REVEALED:
			item_button.text = item_name
		else:
			item_button.text = "??????"
			
		item_button.disabled = not checkMaterials(item, type)
		
		item_id_list.append(item_number)
		item_list.add_child(item_button)
		item_list.children.append(item_button)
		item_button.desired_state = menu
		item_button.state_machine = state_machine
		item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		item_button.custom_minimum_size.x = 250
		item_button.flat = true
		item_button["theme_override_styles/focus"] = item_list.button_glow
		item_button.pressed.connect(self.on_item_button_pressed.bind(item_button))
		item_button.focus_entered.connect(self.on_item_focused.bind(item_button))
	
func getItemsFromCompendium(type):
	var compendium = getCompendium(type)
	return compendium

func getItemFromCompendium(index: int, type):
	var compendium = getCompendium(type)
	var hector_stats: HectorStats = Global.player.stats
	return hector_stats.searchItemInCompendium(index, compendium)
	
func getInventory(type):
	var inventories: HectorStats = Global.player.stats
	if type is int and (type == Weapon.Type.SWORD or type == Weapon.Type.AXE or type == Weapon.Type.FIST):
		return inventories.weapon_inventory
	elif type == "Headgear":
		return inventories.head_inventory
	elif type == "Body":
		return inventories.body_inventory
	elif type == "Legs":
		return inventories.legs_inventory

	
func getCompendium(type):
	var compendiums: HectorStats = Global.player.stats
	if type is int and (type == Weapon.Type.SWORD or type == Weapon.Type.AXE or type == Weapon.Type.FIST):
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
	
	for material_item in item.recipe:
		match material_item["inventory"]:
			Weapon.Inventory.weapon:
				material_inventory = hector_stats.weapon_inventory
				material_compendium = hector_stats.weapon_compendium
			Weapon.Inventory.headgear:
				material_inventory = hector_stats.head_inventory
				material_compendium = hector_stats.headgear_compendium

			Weapon.Inventory.body:
				material_inventory = hector_stats.body_inventory
				material_compendium = hector_stats.body_compendium
			
			Weapon.Inventory.item:
				material_inventory = hector_stats.item_inventory
				material_compendium = hector_stats.item_compendium.Compendium
				

				
		if hector_stats.findItem(material_item["id"], material_inventory) < material_item["quantity"]:
			return false
			
	return true

func craftItem(item, type, button_position) -> void:
	var hector_stats: HectorStats = Global.player.stats
	var material_inventory
	var material_compendium
	var item_data = hector_stats.searchItemInCompendium(item, getCompendium(type))
	
	for material_item in item_data.recipe:
		match material_item["inventory"]:
			Weapon.Inventory.weapon:
				material_inventory = hector_stats.weapon_inventory
				material_compendium = hector_stats.weapon_compendium
			Weapon.Inventory.headgear:
				material_inventory = hector_stats.head_inventory
				material_compendium = hector_stats.headgear_compendium

			Weapon.Inventory.body:
				material_inventory = hector_stats.body_inventory
				material_compendium = hector_stats.body_compendium

			Weapon.Inventory.item:
				material_inventory = hector_stats.item_inventory
				material_compendium = hector_stats.item_compendium

		hector_stats.removeItemCopies(material_item["id"], material_item["quantity"], material_inventory)
	
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
	
	craft_text.text = "Produced [color=yellow]" + item_name + "[/color]!"
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
		
	for material_item in item.recipe:
		var material_entry: HBoxContainer = HBoxContainer.new()
		var material_icon: TextureRect = TextureRect.new()
		var material_name: RichTextLabel = RichTextLabel.new()
		var material_quantity: RichTextLabel = RichTextLabel.new()
		
		material_icon.custom_minimum_size = Vector2(32, 32)
		material_name.custom_minimum_size = Vector2(200, 32)
		material_quantity.custom_minimum_size = Vector2(70, 32)
		material_name.bbcode_enabled = true
		material_quantity.bbcode_enabled = true
		
		var hector_stats: HectorStats = Global.player.stats
		var material_inventory
		var material_compendium
		var name_property: String
		var possessed_quantity: int = 0
		
		match material_item["inventory"]:
			Weapon.Inventory.weapon:
				material_inventory = hector_stats.weapon_inventory
				material_compendium = hector_stats.weapon_compendium
				name_property = "item_name"
			Weapon.Inventory.headgear:
				material_inventory = hector_stats.head_inventory
				material_compendium = hector_stats.headgear_compendium
				name_property = "headgear_name"
			Weapon.Inventory.body:
				material_inventory = hector_stats.body_inventory
				material_compendium = hector_stats.body_compendium
				name_property = "body_name"
			Weapon.Inventory.item:
				material_inventory = hector_stats.item_inventory
				material_compendium = hector_stats.item_compendium.Compendium
				name_property = "item_name"
		var material_data = hector_stats.searchItemInCompendium(material_item["id"], material_compendium)
		possessed_quantity = hector_stats.findItem(material_item["id"], material_inventory)

		material_icon.texture = material_data.icon
		material_name.text = material_data[name_property]
		material_quantity.text = "[right]" + str(possessed_quantity) + "/" + str(material_item["quantity"]) + "[/right]"
		
		if possessed_quantity < material_item["quantity"]:
			material_name.text = "[color=#FF8080]" + material_name.text + "[/color]"
			material_quantity.text = "[right][color=#FF8080]" + material_quantity.text + "[/color][/right]"
		
		material_entry.add_child(material_icon)
		material_entry.add_child(material_name)
		material_entry.add_child(material_quantity)
		material_list.add_child(material_entry)


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
		item_list.get_child(item_to_craft).grab_focus()
		menu.accessed_menu = 1
