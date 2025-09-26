extends Node
class_name HectorStats
@export var Stats: Dictionary #Current stats with boosts
@export var Growths: Dictionary #Total stat gains from level 1 to 99
@export var Boosts: Dictionary #Stat boosts from equipment and permanent pick-up upgrades
@export var Initial: Dictionary #Initial starting stats
@export var Bases: Dictionary = Initial.duplicate(true) #Current stats without boosts
@export var Estimated: Dictionary #Stat calculations in the equip menu when selecting an item
@export var equipment: Dictionary #Currently equipped item slots
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
@export var status: Array[int]
@export var weapon_proficiency: Array[Dictionary]
@export var file_name: String

enum Ailment {
	GOOD,
	POISON,
	CURSE,
	STONE
}

var current_status: Ailment = Ailment.GOOD

var picked_items: Array[bool] #ID list checks for item pick-up flags
var hint_flags: Array[bool] #ID list checks for hints
var event_flags: Array[bool] #ID list checks for events (combat rooms and bosses are excluded)
var stage_name_flags: Array[bool] #ID list checks for stage name display
var combat_flags: Array[bool] #ID list checks for combat rooms and bosses
var tutorial_flags: Array[bool] #ID list checks for fullscreen tutorial popups
var dialogue_flags: Array[bool] #ID list checks for dialogue scenes
var save_flags: Array[bool] #ID list checks for visited save rooms
var current_area: String = "???"
var map_ratio: String

enum Status {
	REFRESHING_AIR
}

func _ready() -> void:
	for i in range(0, 1000):
		picked_items.append(false)
		hint_flags.append(false)
		event_flags.append(false)
		stage_name_flags.append(false)
		combat_flags.append(false)
		tutorial_flags.append(false)
		dialogue_flags.append(false)
		save_flags.append(false)

func _process(delta: float) -> void:
	Bases["ATK"] = Stats["STR"]/2
	Bases["DEF"] = Stats["CON"]/2
	for i in range(0, status.size()):
		status[i] = max(status[i]-1, 0)
	
func _physics_process(delta: float) -> void:
	play_time.count(delta)

# Finds the # of held copies of a certain item ID in a certain inventory
func findItem(id: int, inventory) -> int:
	for item in inventory:
		if id == item["id"]:
			return item["quantity"]
	return 0

# Adds 1 copy of a certain item ID in a certain inventory
func addItem(id: int, inventory) -> void:
	var copies = findItem(id, inventory)
	if copies == 0:
		inventory.append({"id": id, "quantity": 1})
	else:
		for item in inventory:
			if item["id"] == id:
				item["quantity"] += 1

# Removes 1 copy of a certain item ID in a certain inventory
func removeItem(id: int, inventory) -> void:
	var copies = findItem(id, inventory)
	if copies == 1:
		inventory.erase({"id": id, "quantity": copies})
	else:
		for item in inventory:
			if item["id"] == id:
				item["quantity"] -= 1
				
# Removes multiple copies of a certain item ID in a certain inventory
func removeItemCopies(id: int, qty: int, inventory) -> void:
	var copies = findItem(id, inventory)
	if copies <= qty:
		inventory.erase({"id": id, "quantity": copies})
	elif copies > qty:
		for item in inventory:
			if item["id"] == id:
				item["quantity"] -= qty

# Finds the item ID in a certain compendium
func searchItemInCompendium(id: int, compendium):
	if id < 1:
		return null
	return compendium[id-1]

# Finds the slot number of the item in a certain compendium
func getItemIndexInCompendium(item, compendium: Array) -> int:
	var slot = 1
	for entry in compendium:
		if item == entry:
			return slot
		slot += 1
	return 0
	
func getCurrentWeaponType() -> int:
	var weapon_type: int = 4
	if equipment["weapon"] != 0:
		weapon_type = searchItemInCompendium(equipment["weapon"], weapon_compendium).type
	return weapon_type

func canApplySkill(id: int) -> bool:
	return findItem(id, skill_inventory) > 0 and getCurrentWeaponType() == searchItemInCompendium(id, skill_compendium).weapon_type

func accessoryEquipped(id : int) -> bool:
	return equipment["acc1"] == id or equipment["acc2"] == id
	
func itemEquipped(id: int, slot: String) -> bool:
	return equipment[slot] == id+1
