@tool
extends Control
class_name ShopBuy

@export var purchasable_items: Array[ShopItem]
@export var preview: Dictionary 
@export_tool_button("Shop at level 0", "FileAccess") var parse_button: Callable = parseShop.bind(0)
@export_tool_button("Shop at level 1", "FileAccess") var parse_button_1: Callable = parseShop.bind(1)
@export_tool_button("Shop at level 2", "FileAccess") var parse_button_2: Callable = parseShop.bind(2)
@export var scroll_container: ScrollContainer
@export var gold_label: Label
@export var animation: AnimationPlayer
@export var sound: PolyphonicMenuAudio
@export var text_description: Label
@export var icon_description: TextureRect
@export var item_entries: VBoxContainer
@export var gold_sound: PolyphonicMenuAudio
@export var item_stats: ItemStats
@export var show_item_stats: RichTextLabelWithButtons
var item_quantities: Array[int]
var item_max_held: Array[int]
var item_held: Array[int]
var item_descriptions: Array[String]
var base_item_costs: Array[int]
static var level: int = 0
var cur_index: int = 0
var gold_consumption_tween: Tween
var cur_button_held: String
var cur_button_held_for: float
var holding_button: bool = false
var sliding_active: bool = false
var HOLD_AFTER_SECONDS: float = 0.3
var SLIDE_SPEED: float = 0.075
var sliding_interval: float = 0.03

enum ItemEntryChildren {
	BUTTON,
	TYPE,
	QUANTITY,
	HELD,
	PRICE
}

## Initializes the buy screen.
func initializeBuyScreen() -> void:
	initializeItemEntries()
	cur_index = 0
	item_stats.in_shop = true
	item_stats.can_open = true
	focusOnButton(true)
	
	scroll_container.scroll_vertical = 0
	updateAvailability()

## Focuses on the current button.
func focusOnButton(silent: bool = false) -> void:
	var cur_button: HBoxContainer = item_entries.get_child(cur_index)
	cur_button.get_child(ItemEntryChildren.BUTTON).grab_focus()
	updateDescription()
	item_stats.item = getCompendium(purchasable_items[cur_index].type)[purchasable_items[cur_index].id-1]
	if not silent:
		sound.play_sound_effect_from_library("cursor")
	
## Updates the panel description.
func updateDescription() -> void:
	var cur_button: HBoxContainer = item_entries.get_child(cur_index)
	text_description.text = item_descriptions[cur_index]
	icon_description.texture = cur_button.get_child(ItemEntryChildren.BUTTON).icon
	

## Returns to initial screen.
func closeBuyScreen() -> void:
	item_stats.can_open = false
	show_item_stats.visible = false
	var cur_button: HBoxContainer = item_entries.get_child(cur_index)
	if cur_button:
		cur_button.get_child(ItemEntryChildren.BUTTON).release_focus()
	animation.play_backwards("show")
	await animation.animation_finished
	text_description.text = tr("JULIA_THANKS_AS_ALWAYS")
	icon_description.texture = null
	var shop_screen: Shop = get_parent()
	shop_screen.julia_voice.play_sound_effect_from_library("thanks")
	shop_screen.initial_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	shop_screen.animation.play_backwards("hide_initial")
	shop_screen.default_button.grab_focus()
	process_mode = Node.PROCESS_MODE_DISABLED
	

## Initializes the buttons of items in the buy list.
func initializeItemEntries() -> void:
	const INITIAL_QUANTITY: int = 1
	var STYLEBOX_EMPTY: StyleBoxFlat = StyleBoxFlat.new()
	STYLEBOX_EMPTY.bg_color = Color.TRANSPARENT
	for child in item_entries.get_children():
		child.free()
	
	base_item_costs.clear()
	item_quantities.clear()
	item_max_held.clear()
	item_held.clear()
	item_descriptions.clear()
	var index: int = 0
	for item: ShopItem in purchasable_items:
		if item.show_at_shop_level > level:
			continue
		var item_entry: HBoxContainer = HBoxContainer.new()
		var item_button: Button = Button.new()
		var item_type: Label = Label.new()
		var item_quantity: Label = Label.new()
		var item_held_label: Label = Label.new()
		var item_price: Label = Label.new()
		var item_data = getCompendium(item.type)[item.id-1]
			
		base_item_costs.append(item_data.value)
		item_held.append(Global.player.stats.findItem(item.id, getInventory(item.type)) + int(Global.player.stats.isEquipped(item_data)))
		item_max_held.append(item_data.max_quantity)
		item_quantities.append(min(INITIAL_QUANTITY, item_data.max_quantity-Global.player.stats.findItem(item.id, getInventory(item.type)) - int(Global.player.stats.isEquipped(item_data))))
		item_descriptions.append(item_data[PickUp.getItemDescription(item.type)])
		
		item_button.flat = true
		item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		item_button.expand_icon = true
		item_button.icon = item_data.icon
		item_button.text = item_data[PickUp.getItemName(item.type)]
		item_button.pressed.connect(_onItemSelected)
		item_button.add_theme_stylebox_override("normal", STYLEBOX_EMPTY)
		item_button.add_theme_stylebox_override("focus", STYLEBOX_EMPTY)
		item_button.add_theme_stylebox_override("hover", STYLEBOX_EMPTY)
		item_button.add_theme_stylebox_override("pressed", STYLEBOX_EMPTY)
		item_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		item_quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_held_label.text = str(item_held.back())
		item_held_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_price.text = str(item_data.value * item_quantities.back())
		item_price.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		item_type.text = PickUp.ItemType.keys()[item.type]
		item_type.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		item_button.custom_minimum_size.x = 302
		item_button.custom_minimum_size.y = 32
		item_type.custom_minimum_size.x = 150
		item_quantity.custom_minimum_size.x = 145
		item_held_label.custom_minimum_size.x = 50
		item_price.custom_minimum_size.x = 115
		
		item_entry.add_child(item_button)
		item_entry.add_child(item_type)
		item_entry.add_child(item_quantity)
		item_entry.add_child(item_held_label)
		item_entry.add_child(item_price)
		item_entries.add_child(item_entry)
		
		updateQuantityLabel(index)
		index += 1
	
## Shows item data in the preview property. (To use inside the editor)
func parseShop(shop_level: int) -> void:
	preview.clear()
	for item: ShopItem in purchasable_items:
		if item.show_at_shop_level > shop_level:
			continue
		var name_property: String = PickUp.getItemName(item.type)
		var item_name: String = getCompendium(item.type)[item.id-1][name_property]
		var item_price: int = getCompendium(item.type)[item.id-1].value
		preview[item_name] = item_price

## Given the type of the item, returns the compendium that holds it.
func getCompendium(type):
	Game.get_singleton().update_static_compendiums = true
	var cur_compendium: Array
	match type:
		PickUp.ItemType.ITEM:
			cur_compendium = Game.item_compendium_static.Compendium
			return cur_compendium
		PickUp.ItemType.WEAPON:
			cur_compendium = Game.weapon_compendium_static
			return cur_compendium
		PickUp.ItemType.HEADGEAR:
			cur_compendium = Game.headgear_compendium_static
			return cur_compendium
		PickUp.ItemType.RELIC:
			cur_compendium = Game.relic_compendium_static
			return cur_compendium
		PickUp.ItemType.ARTIFACT:
			cur_compendium = Game.artifact_compendium_static
			return cur_compendium
		PickUp.ItemType.BODY:
			cur_compendium = Game.body_compendium_static
			return cur_compendium
		PickUp.ItemType.LEGS:
			cur_compendium = Game.legs_compendium_static
			return cur_compendium
		PickUp.ItemType.ACCESSORY:
			cur_compendium = Game.accessory_compendium_static
			return cur_compendium
		PickUp.ItemType.SKILL:
			cur_compendium = Game.skill_compendium_static
			return cur_compendium

## Gets the associated inventory of a certain item type.
func getInventory(type: PickUp.ItemType) -> Array[Dictionary]:
	var lists = Global.player.stats
	match type:
		PickUp.ItemType.ITEM:
			return lists.item_inventory
		PickUp.ItemType.WEAPON:
			return lists.weapon_inventory
		PickUp.ItemType.ARTIFACT:
			return lists.artifact_inventory
		PickUp.ItemType.RELIC:
			return lists.relic_inventory
		PickUp.ItemType.HEADGEAR:
			return lists.head_inventory
		PickUp.ItemType.BODY:
			return lists.body_inventory
		PickUp.ItemType.LEGS:
			return lists.legs_inventory
		PickUp.ItemType.ACCESSORY:
			return lists.acc_inventory
		PickUp.ItemType.SKILL:
			return lists.skill_inventory
		_:
			return []
			
func _input(event: InputEvent) -> void:
	const ACTIONS: Array[String] = ["ui_right", "ui_left", "ui_up", "ui_down"]
	for action in ACTIONS:
		if event.is_action(action):
			if cur_button_held != action:
				cur_button_held_for = 0
			cur_button_held = action
			holding_button = true
			
	if cur_button_held != "" and Input.is_action_just_released(cur_button_held):
		cur_button_held_for = 0
		cur_button_held = ""
		holding_button = false

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	show_item_stats.visible = item_stats.item != null and item_stats.item is not Item
	if item_stats.visible:
		show_item_stats.new_text = " " + tr("HIDE_ITEM_STATS_LABEL")
	else:
		show_item_stats.new_text = " " + tr("SHOW_ITEM_STATS_LABEL")
		
	gold_label.text = str(Shop.displayed_gold)
	if animation.is_playing():
		return
		
	if holding_button:
		cur_button_held_for += delta
	sliding_active = cur_button_held_for >= HOLD_AFTER_SECONDS
	
	if not sliding_active or sliding_interval < 0:
		sliding_interval = SLIDE_SPEED
	else:
		sliding_interval -= delta
	
	if Input.is_action_just_pressed("ui_cancel"):
		closeBuyScreen()
	elif Input.is_action_just_pressed("ui_right") or (Input.is_action_pressed("ui_right") and sliding_interval < 0):
		increaseQuantity(base_item_costs[cur_index])
	elif Input.is_action_just_pressed("ui_left") or (Input.is_action_pressed("ui_left") and sliding_interval < 0):
		decreaseQuantity(base_item_costs[cur_index])
	elif Input.is_action_just_pressed("ui_up") or (Input.is_action_pressed("ui_up") and sliding_interval < 0):
		cur_index = posmod(cur_index-1, item_entries.get_child_count())
		focusOnButton()
		updateAvailability()
	elif Input.is_action_just_pressed("ui_down") or (Input.is_action_pressed("ui_down") and sliding_interval < 0):
		cur_index = posmod(cur_index+1, item_entries.get_child_count())
		focusOnButton()
		updateAvailability()

## Buys a certain number of copies of a certain item with specified type.
func buyItem(item: int, type: PickUp.ItemType, quantity: int, cost: int) -> void:
	var total_cost: int = cost*quantity
	
	if quantity == 0:
		sound.play_sound_effect_from_library("denied")
		return

	if total_cost > Global.player.stats.Stats["GOLD"]:
		sound.play_sound_effect_from_library("denied")
		get_parent().julia_voice.play_sound_effect_from_library("no_money")
		return
	
	get_parent().julia_voice.play_sound_effect_from_library(["anything_else", "thank_you"].pick_random())
	sound.play_sound_effect_from_library("confirm")
	var player_inventory = getInventory(type)
	item_held[cur_index] += quantity
	item_quantities[cur_index] = 0
	item_entries.get_child(cur_index).get_child(ItemEntryChildren.HELD).text = str(item_held[cur_index])
	updateQuantityLabel(cur_index)
	updateCostLabel(cur_index)
	Global.player.stats.addItem(item, player_inventory, quantity)
	Global.player.stats.Stats["GOLD"] -= total_cost
	updateAvailability()
	if gold_consumption_tween != null and gold_consumption_tween.is_running():
		gold_consumption_tween.kill()
		gold_sound.stop()
	gold_consumption_tween = get_tree().create_tween()
	gold_consumption_tween.finished.connect(finishGoldSound)
	gold_sound.play_sound_effect_from_library("gold_consuming")
	gold_consumption_tween.tween_property(Shop, "displayed_gold", Global.player.stats.Stats["GOLD"], log(Shop.displayed_gold - Global.player.stats.Stats["GOLD"])*0.1)

func finishGoldSound() -> void:
	gold_sound.stop()
	gold_sound.play_sound_effect_from_library("gold_finished")

## Increases the quality slider of the currently selected item by 1 and recalculates the total cost.
func increaseQuantity(price: int) -> void:
	if item_quantities[cur_index] < item_max_held[cur_index] - item_held[cur_index]:
		item_quantities[cur_index] += 1
		updateQuantityLabel(cur_index)
		updateCostLabel(cur_index)
		sound.play_sound_effect_from_library("cursor")
	else:
		sound.play_sound_effect_from_library("denied")

## Decrease the quality slider of the currently selected item by 1 and recalculates the total cost.
func decreaseQuantity(price: int) -> void:
	if item_quantities[cur_index] > min(item_max_held[cur_index] - item_held[cur_index], 1):
		sound.play_sound_effect_from_library("cursor")
		item_quantities[cur_index] -= 1
		updateQuantityLabel(cur_index)
		updateCostLabel(cur_index)
	else:
		sound.play_sound_effect_from_library("denied")

## Updates the quantity of the currently selected item
func updateQuantityLabel(index: int) -> void:
	var qty_label: Label = item_entries.get_child(index).get_child(ItemEntryChildren.QUANTITY)
	qty_label.text = ""
	if item_quantities[index] > min(item_max_held[index] - item_held[index], 1):
		qty_label.text += "< "
	else:
		qty_label.text += "   "
	qty_label.text += str(item_quantities[index])
	if item_quantities[index] < item_max_held[index] - item_held[index]:
		qty_label.text += " >"
	else:
		qty_label.text += "   "
	
	if item_quantities[index] == 0:
		qty_label.self_modulate = Color.CRIMSON
	else:
		qty_label.self_modulate = Shop.SELECTED_ITEM_COLOR
		
	for type in ItemEntryChildren.keys():
		if type != "BUTTON":
			item_entries.get_child(index).get_child(ItemEntryChildren[type]).self_modulate = Shop.SELECTED_ITEM_COLOR
		if type == "PRICE" and Global.player.stats.Stats["GOLD"] >= base_item_costs[index]*item_quantities[index]:
			item_entries.get_child(index).get_child(ItemEntryChildren[type]).self_modulate = Shop.SELECTED_ITEM_COLOR
			
	(item_entries.get_child(index).get_child(ItemEntryChildren.BUTTON) as Button).add_theme_color_override("font_focus_color", Shop.SELECTED_ITEM_COLOR)
	(item_entries.get_child(index).get_child(ItemEntryChildren.BUTTON) as Button).add_theme_color_override("font_color", Shop.SELECTED_ITEM_COLOR)
	(item_entries.get_child(index).get_child(ItemEntryChildren.BUTTON) as Button).add_theme_color_override("font_pressed_color", Shop.SELECTED_ITEM_COLOR)



## Updates the item cost of the currently selected item
func updateCostLabel(index: int) -> void:
	var price_label: Label = item_entries.get_child(index).get_child(ItemEntryChildren.PRICE)
	
	if Global.player.stats.Stats["GOLD"] < base_item_costs[index]*item_quantities[index]:
		price_label.self_modulate = Color.CRIMSON
	else:
		price_label.self_modulate = Shop.SELECTED_ITEM_COLOR

	price_label.text = str(item_quantities[index]*base_item_costs[index])

## Updates if each item in the shop is purchasable or not based on how much gold the player has when this function is called.
func updateAvailability() -> void:
	for item_entry in item_entries.get_children():
		if int(item_entry.get_child(ItemEntryChildren.PRICE).text) > Global.player.stats.Stats["GOLD"] or int(item_entry.get_child(ItemEntryChildren.QUANTITY).text) == 0:
			setItemEntryColor(item_entry, Shop.UNAVAILABLE_ITEM_COLOR)
		else:
			setItemEntryColor(item_entry, Shop.AVAILABLE_ITEM_COLOR)
			
## Updates the color of an item entry.
func setItemEntryColor(item_entry: HBoxContainer, color: Color) -> void:
	if item_entries.get_child(cur_index) == item_entry:
		if item_quantities[cur_index] == 0:
			color = Color.CRIMSON
		else:
			color = Shop.SELECTED_ITEM_COLOR
	
	for type in ItemEntryChildren.keys():
		if type != "BUTTON":
			item_entry.get_child(ItemEntryChildren[type]).self_modulate = color
		if type == "PRICE" and color == Shop.SELECTED_ITEM_COLOR and Global.player.stats.Stats["GOLD"] < base_item_costs[cur_index]*item_quantities[cur_index]:
			item_entry.get_child(ItemEntryChildren[type]).self_modulate = Color.CRIMSON
			
	(item_entry.get_child(ItemEntryChildren.BUTTON) as Button).add_theme_color_override("font_focus_color", color)
	(item_entry.get_child(ItemEntryChildren.BUTTON) as Button).add_theme_color_override("font_color", color)
	(item_entry.get_child(ItemEntryChildren.BUTTON) as Button).add_theme_color_override("font_pressed_color", color)

## Presses the i-th item button in the buy list
func _onItemSelected() -> void:
	buyItem(purchasable_items[cur_index].id, purchasable_items[cur_index].type, item_quantities[cur_index], base_item_costs[cur_index])
