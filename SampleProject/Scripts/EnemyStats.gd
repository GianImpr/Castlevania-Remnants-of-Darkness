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
var enemy_parent_node: Node
const PICK_UP_SCENE_PATH: String = "res://SampleProject/extra_scenes/items/pick_up.tscn"
const HEART_SCENE_PATH: String = "res://SampleProject/extra_scenes/items/heart.tscn"
const MONEY_SCENE_PATH: String = "res://SampleProject/extra_scenes/items/money.tscn"
var pick_up_scene: Resource = preload(PICK_UP_SCENE_PATH)
var heart_scene: Resource = preload(HEART_SCENE_PATH)
var money_scene: Resource = preload(MONEY_SCENE_PATH)

func _ready():
	if Global.game.difficulty == Global.game.Difficulty.CRAZY:
		LV += 10
		DEF *= 1.5
		RES *= 1.5
		ATK = (ATK + LV) * 1.5
	enemy_parent_node = get_parent().get_parent()

# Determines what the enemy should drop, should be called when an enemy is dying
func determineDrop(include_misc_items: bool) -> void:
	var common_rate: float = calculateDropRate(common_drop_rate)
	var rare_rate: float = calculateDropRate(rare_drop_rate)
	const MIN_RANDOM_NUMBER: float = 0
	const MAX_RANDOM_NUMBER: float = 1
	const HEART_DROP_RATE: float = 0.25
	const MONEY_DROP_RATE: float = 0.3
	var random_number: float = randf_range(MIN_RANDOM_NUMBER, MAX_RANDOM_NUMBER)
	if random_number > common_rate and random_number <= rare_rate:
		dropItem(rare_drop_id, rare_drop_category)
	elif random_number <= common_drop_rate:
		dropItem(common_drop_id, common_drop_category)
		
	if not include_misc_items:
		return
		
	elif random_number <= HEART_DROP_RATE and (Global.player.unlocked_magic or Global.player.innocent_devil != null):
		dropMisc(heart_scene)
	elif random_number <= MONEY_DROP_RATE:
		dropMisc(money_scene)

# Calculates the drop rate for an item, max 50% chance
func calculateDropRate(rate: float) -> float:
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
	enemy_parent_node.add_child(pick_up)
	pick_up.global_position = get_parent().global_position

# Drops a random heart or money
func dropMisc(scene: PackedScene) -> void:
	var misc_drop = scene.instantiate()
	enemy_parent_node.add_child(misc_drop)
	misc_drop.global_position = get_parent().global_position
	
