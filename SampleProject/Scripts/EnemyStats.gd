extends Node
class_name EnemyStats
@export var enemy_name: String
@export var LV: int
@export var HP: int
@export var ATK: int
@export var DEF: int
@export var RES: int
@export var EXP: int
@export var common_drop_id: int = 0
@export var common_drop_category: PickUp.ItemType
@export var common_drop_rate: float = 0
@export var rare_drop_id: int = 0
@export var rare_drop_category: PickUp.ItemType
@export var rare_drop_rate: float = 0
@export var weaknesses: Array[Global.Attribute]
@export var tolerances: Array[Global.Attribute]
var enemy_parent_node: Node
const PICK_UP_SCENE_PATH: String = "res://SampleProject/extra_scenes/items/pick_up.tscn"
const HEART_SCENE_PATH: String = "res://SampleProject/extra_scenes/items/heart.tscn"
const MONEY_SCENE_PATH: String = "res://SampleProject/extra_scenes/items/money.tscn"
static var pick_up_scene: Resource = preload(PICK_UP_SCENE_PATH)
static var heart_scene: Resource = preload(HEART_SCENE_PATH)
static var money_scene: Resource = preload(MONEY_SCENE_PATH)
static var CRAZY_MODE_STAT_MULTIPLIER: float = 1.5
static var CRAZY_MODE_LEVEL_BOOST: float = 10
static var SIMPLIFIED_MODE_STAT_MULTIPLIER: float = 0.5

var enemy_entry: EnemyEntry

func _ready():
	enemy_entry = findEntry()
	if Global.game.difficulty == Game.Difficulty.CRAZY:
		LV += CRAZY_MODE_LEVEL_BOOST
		DEF *= CRAZY_MODE_STAT_MULTIPLIER
		RES *= CRAZY_MODE_STAT_MULTIPLIER
		ATK = (ATK + LV) * CRAZY_MODE_STAT_MULTIPLIER
	elif Global.game.difficulty == Game.Difficulty.SIMPLIFIED:
		ATK *= SIMPLIFIED_MODE_STAT_MULTIPLIER
		DEF *= SIMPLIFIED_MODE_STAT_MULTIPLIER
		RES *= SIMPLIFIED_MODE_STAT_MULTIPLIER
	enemy_parent_node = get_parent().get_parent()

# Determines what the enemy should drop, should be called when an enemy is dying
func determineDrop(include_misc_items: bool) -> void:
	var common_rate: float = calculateDropRate(common_drop_rate)
	var rare_rate: float = calculateDropRate(rare_drop_rate)
	const MIN_RANDOM_NUMBER: float = 0
	const MAX_RANDOM_NUMBER: float = 1
	const HEART_DROP_RATE: float = 0.25
	const MONEY_DROP_RATE: float = 0.3
	const RED_SCARF_BONUS_MULTIPLIER: float = 1.3
	var heart_drop_multiplier: float = 1
	var random_number: float = randf_range(MIN_RANDOM_NUMBER, MAX_RANDOM_NUMBER)
	if random_number > common_rate and random_number <= common_rate + rare_rate:
		dropItem(rare_drop_id, rare_drop_category)
		enemy_entry.rare_drop_revealed = true
		return
	elif random_number <= common_rate:
		dropItem(common_drop_id, common_drop_category)
		enemy_entry.common_drop_revealed = true
		return
		
	if not include_misc_items:
		return
		
	random_number = randf_range(MIN_RANDOM_NUMBER, MAX_RANDOM_NUMBER)
	
	if Global.player.stats.accessoryEquipped(Accessory.Accessories.RED_SCARF):
		heart_drop_multiplier = RED_SCARF_BONUS_MULTIPLIER
		
	if random_number <= HEART_DROP_RATE*heart_drop_multiplier and (Global.player.unlocked_magic or Global.player.innocent_devil != null):
		dropMisc(heart_scene)
	elif random_number <= MONEY_DROP_RATE:
		dropMisc(money_scene)

# Calculates the drop rate for an item, max 50% chance
static func calculateDropRate(rate: float) -> float:
	const DROP_RATIO: float = 256
	const MAX_DROP_RATE: float = 0.5
	return min(Global.player.stats.Stats["LCK"]*rate/DROP_RATIO, MAX_DROP_RATE)

# Drops the item
func dropItem(id: int, type: PickUp.ItemType) -> void:
	if id == 0:
		return
	var pick_up: PickUp = pick_up_scene.instantiate()
	pick_up.id = id
	pick_up.type = type
	pick_up.global_position = get_parent().global_position
	enemy_parent_node.add_child(pick_up)

# Drops a random heart or money
func dropMisc(scene: PackedScene) -> void:
	var misc_drop = scene.instantiate()
	if "fly_high" in misc_drop:
		misc_drop.fly_high = true
	misc_drop.global_position = get_parent().global_position
	enemy_parent_node.add_child(misc_drop)
	
func findEntry() -> EnemyEntry:
	for i in range(0, Game.enemy_data.size()):
		if enemy_name == Game.enemy_data[i][EnemyEntry.Stats.NAME]:
			return Game.get_singleton().enemy_compendium[i]
	
	push_error("No entry found.")
	return null
