@tool
extends Control
class_name ShopBuy

@export var purchasable_items: Array[ShopItem]
@export var preview: Dictionary 
@export_tool_button("Shop at level 0", "FileAccess") var parse_button: Callable = parseShop.bind(0)
@export_tool_button("Shop at level 1", "FileAccess") var parse_button_1: Callable = parseShop.bind(1)
@export_tool_button("Shop at level 2", "FileAccess") var parse_button_2: Callable = parseShop.bind(2)
@export var gold_label: Label
@export var animation: AnimationPlayer
var item_entries: VBoxContainer
var item_quantities: Array[int]
var item_max_held: Array[int]
var item_held: Array[int]
var base_item_costs: Array[int]
static var level: int = 0
var cur_index: int = 0

const UNAVAILABLE_COLOR: Color = Color.DIM_GRAY
const AVAILABLE_COLOR: Color = Color.WHITE

enum ItemEntryChildren {
	BUTTON,
	TYPE,
	QUANTITY,
	HELD,
	PRICE
}

## Initializes the buttons of items in the buy list.
func initializeItemEntries() -> void:
	base_item_costs.clear()
	item_quantities.clear()
	item_max_held.clear()
	cur_index = 0
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
		
		if item.data.value > Global.player.stats.Stats["Gold"]:
			item_entry.modulate = UNAVAILABLE_COLOR
			
		base_item_costs.append(item_data.value)
		item_quantity.append(1)
		item_held.append(Global.player.stats.findItem(item.id, getInventory(item.type)) + int(Global.player.stats.isEquipped(item_data)))
		item_max_held.append(item_data.max_quantity)
		
		item_button.flat = true
		item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		item_button.expand_icon = true
		item_button.icon = item_data.icon
		item_button.text = item_data[PickUp.getItemName(item.type)]
		item_quantity.text = "1"
		item_held_label.text = str()
		item_price.text = str(item_data.value)
		item_type.text = PickUp.ItemType.keys()[item.type]
		
		item_button.custom_minimum_size.x = 302
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

func _process(delta: float) -> void:
	gold_label.text = str(Shop.displayed_gold)
	

## Buys a certain number of copies of a certain item with specified type.
func buyItem(item: int, type: PickUp.ItemType, quantity: int, cost: int) -> void:
	var player_inventory = getInventory(type)
	Global.player.stats.addItem(item, player_inventory, quantity)
	Global.player.stats.Stats["Gold"] -= cost*quantity

## Increases the quality slider of the currently selected item by 1 and recalculates the total cost.
func increaseQuantity(price: int) -> void:
	if item_quantities[cur_index] < item_max_held[cur_index] - item_held[cur_index]:
		item_quantities[cur_index] += 1

func _on_item_selected() -> void:
	return
