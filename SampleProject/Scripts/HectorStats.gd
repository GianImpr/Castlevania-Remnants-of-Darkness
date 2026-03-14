extends Node
class_name HectorStats
@export var poison_tick_timer: Timer
@export var Stats: Dictionary ##Current stats with boosts
@export var Growths: Dictionary ##Total stat gains from level 1 to 99
@export var Boosts: Dictionary ##Stat boosts from equipment and permanent pick-up upgrades
@export var Initial: Dictionary ##Initial starting stats
@export var Bases: Dictionary = Initial.duplicate(true) ##Current stats without boosts
@export var Estimated: Dictionary ##Stat calculations in the equip menu when selecting an item
@export var equipment: Dictionary ##Currently equipped item slots
@export var item_inventory: Array[Dictionary]
@export var weapon_inventory: Array[Dictionary]
@export var artifact_inventory: Array[Dictionary]
@export var relic_inventory: Array[Dictionary]
@export var head_inventory: Array[Dictionary]
@export var body_inventory: Array[Dictionary]
@export var legs_inventory: Array[Dictionary]
@export var acc_inventory: Array[Dictionary]
@export var skill_inventory: Array[Dictionary]
@export var weapon_compendium: Array[Weapon]
@export var item_compendium: ItemCompendium
@export var headgear_compendium: Array[Headgear]
@export var body_compendium: Array[Body]
@export var legs_compendium: Array[Legs]
@export var accessory_compendium: Array[Accessory]
@export var skill_compendium: Array[Skill]
@export var relic_compendium: Array[Relic]
@export var artifact_compendium: Array[Artifact]
@export var enemy_compendium: Array[EnemyEntry]
@export var play_time: Hour
@export var status: Array[float]
@export var weapon_proficiency: Array[Dictionary]
@export var file_name: String
static var equipItem: Callable

enum Ailment {
	GOOD,
	POISON,
	CURSE,
	STONE,
	ENFEEBLE
}

const EQUIPMENT_SLOTS = {
	WEAPON = "weapon",
	ARTIFACT = "artifact",
	RELIC = "relic",
	HEADGEAR = "head",
	BODY = "body",
	LEGS = "legs",
	ACC_1 = "acc1",
	ACC_2 = "acc2"
}

var current_status: Ailment = Ailment.GOOD

var picked_items: Array[bool] ##ID list checks for item pick-up flags
var hint_flags: Array[bool] ##ID list checks for hints
var event_flags: Array[bool] ##ID list checks for events (combat rooms and bosses are excluded)
var stage_name_flags: Array[bool] ##ID list checks for stage name display
var combat_flags: Array[bool] ##ID list checks for combat rooms and bosses
var tutorial_flags: Array[bool] ##ID list checks for fullscreen tutorial popups
var dialogue_flags: Array[bool] ##ID list checks for dialogue scenes
var save_flags: Array[bool] ##ID list checks for visited save rooms
var wall_flags: Array[bool] ##ID list checks for broken walls
var current_area: String = "???"
var map_ratio: String

static var change_slot_icon: Callable

const CURSE_MP_DRAIN_PER_SECOND: int = 50

enum Status {
	REFRESHING_AIR,
	POISON,
	CURSE,
	ENFEEBLE,
	TIME_HEAL,
	STONE
}

func _input(event: InputEvent) -> void:
	var compendiums = [weapon_compendium, artifact_compendium, relic_compendium, body_compendium, headgear_compendium, legs_compendium, accessory_compendium, item_compendium.Compendium, skill_compendium]
	var inventories = [weapon_inventory, artifact_inventory, relic_inventory, body_inventory, head_inventory, legs_inventory, acc_inventory, item_inventory, skill_inventory]
	if event.is_action_released("debug"):
		for i in range(0, save_flags.size()):
			save_flags[i] = true
		Global.player.unlockMagic()
		for i in range(0, compendiums.size()):
			for j in range(1, compendiums[i].size()+1):
				addItem(j, inventories[i], 9)

func _ready() -> void:
	if poison_tick_timer.get_parent() == null:
		add_child(poison_tick_timer)
	for i in range(0, 1000):
		picked_items.append(false)
		hint_flags.append(false)
		event_flags.append(false)
		stage_name_flags.append(false)
		combat_flags.append(false)
		tutorial_flags.append(false)
		dialogue_flags.append(false)
		save_flags.append(false)
		wall_flags.append(false)

func _process(delta: float) -> void:
	Stats["FP"] = Stats["MFP"] - 1
	Bases["ATK"] = Stats["STR"]/2
	Bases["DEF"] = Stats["CON"]/2
	for i in range(0, status.size()):
		status[i] = max(status[i]-delta, 0)

	if status[Status.ENFEEBLE] > 0:
		Stats["Guard"] = 0

	if status[Status.CURSE] > 0:
		Stats["MP"] = max(Stats["MP"]-delta*CURSE_MP_DRAIN_PER_SECOND, 0)
		
	if status[Status.POISON] > 0 and poison_tick_timer.is_stopped():
		if not poison_tick_timer.timeout.is_connected(poisonTick):
				poison_tick_timer.timeout.connect(poisonTick)
		poison_tick_timer.start()
	elif status[Status.POISON] == 0 and not poison_tick_timer.is_stopped():
		poison_tick_timer.stop()

func _physics_process(delta: float) -> void:
	play_time.count(delta)

func poisonTick() -> void:
	if Stats["HP"] == 1 or Global.player.stats.status[Global.player.stats.Status.POISON] == 0:
		return

	var damage: int = min(max(round(Stats["MHP"]/100.0), 1), Stats["HP"]-1)
	Stats["HP"] -= damage
	Global.player.damage_popup.popup(damage, 0)

## Finds the number of held copies of a certain item ID in a certain inventory.
func findItem(id: int, inventory) -> int:
	for item in inventory:
		if id == item["id"]:
			return item["quantity"]
	return 0

## Adds copies of a certain item ID in a certain inventory.
func addItem(id: int, inventory, copies_to_add: int = 1) -> void:
	var copies = findItem(id, inventory)
	if copies == 0:
		inventory.append({"id": id, "quantity": copies_to_add})
	else:
		for item in inventory:
			if item["id"] == id:
				item["quantity"] += copies_to_add

## Removes 1 copy of a certain item ID in a certain inventory.
func removeItem(id: int, inventory, remove_from_wheel: bool = false) -> void:
	var copies = findItem(id, inventory)
	if copies == 1:
		inventory.erase({"id": id, "quantity": copies})
		if inventory == weapon_inventory and remove_from_wheel:
			removeWeaponInWheel(id)
	else:
		for item in inventory:
			if item["id"] == id:
				item["quantity"] -= 1
	
				
## Removes multiple copies of a certain item ID in a certain inventory.
## Returns true if held copies >= qty, else returns false.
func removeItemCopies(id: int, qty: int, inventory, remove_from_wheel: bool = false) -> bool:
	var copies = findItem(id, inventory)
	if copies <= qty:
		inventory.erase({"id": id, "quantity": copies})
		if inventory == weapon_inventory and remove_from_wheel:
			removeWeaponInWheel(id)
		return copies == qty
	else:
		for item in inventory:
			if item["id"] == id:
				item["quantity"] -= qty
		return true
				

## Removes the specified weapon from the weapon wheel, if present.
func removeWeaponInWheel(id: int) -> void:
	for i in range(0, EquipMenu.quick_weapons.size()):
		if EquipMenu.quick_weapons[i] == weapon_compendium[id-1]:
			EquipMenu.quick_weapons[i] = null

## Finds the item ID in a certain compendium.
func searchItemInCompendium(id: int, compendium):
	if id < 1:
		return null
	return compendium[id-1]

## Finds the slot number of the item in a certain compendium.
func getItemIndexInCompendium(item, compendium: Array) -> int:
	var slot = 1
	for entry in compendium:
		if item == entry:
			return slot
		slot += 1
	return 0

## Returns the current weapon type the player has equipped.
func getCurrentWeaponType() -> int:
	var weapon_type: int = 4
	if equipment["weapon"] != 0:
		weapon_type = searchItemInCompendium(equipment["weapon"], weapon_compendium).type
	return weapon_type

## Checks if player can use this skill
func canApplySkill(id: int) -> bool:
	return findItem(id, skill_inventory) > 0 and getCurrentWeaponType() == searchItemInCompendium(id, skill_compendium).weapon_type

## Checks if the player has this accessory equipped
func accessoryEquipped(id : int) -> bool:
	return equipment["acc1"] == id or equipment["acc2"] == id

## Checks if the player has this item equipped, with specified slot.
func itemEquipped(id: int, slot: String) -> bool:
	return equipment[slot] == id+1

## Checks if the player has this item equipped.
func isEquipped(item) -> bool:
	var inventories: Array = [accessory_compendium, accessory_compendium, artifact_compendium, body_compendium, headgear_compendium, legs_compendium, relic_compendium, weapon_compendium]
	var slots: Array = equipment.keys()
	for i in inventories.size():
		if equipment[slots[i]] > 0:
			var equipped_item = searchItemInCompendium(equipment[slots[i]], inventories[i])
			if equipped_item == item:
				return true
	return false
	
## Removes the item from the player's equipped slot.
func removeEquippedItem(item) -> void:
	var inventories: Array = [accessory_compendium, accessory_compendium, artifact_compendium, body_compendium, headgear_compendium, legs_compendium, relic_compendium, weapon_compendium]
	var equip_icon_order: Array = [EquipButtons.EquipSlots.ACC_1, EquipButtons.EquipSlots.ACC_2, EquipButtons.EquipSlots.ARTIFACT, EquipButtons.EquipSlots.BODY, EquipButtons.EquipSlots.HEADGEAR, EquipButtons.EquipSlots.LEGS, EquipButtons.EquipSlots.RELIC, EquipButtons.EquipSlots.WEAPON]
	var slots: Array = equipment.keys()
	for i in inventories.size():
		if equipment[slots[i]] > 0:
			var equipped_item = searchItemInCompendium(equipment[slots[i]], inventories[i])
			if equipped_item == item:
				equipment[slots[i]] = 0
				change_slot_icon.call(equip_icon_order[i], "", null)
				return
	push_error("removeEquippedItem: Item not found")
