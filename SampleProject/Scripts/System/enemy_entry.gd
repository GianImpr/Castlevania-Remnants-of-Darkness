extends Resource
class_name EnemyEntry

@export var enemy_scene: PackedScene
@export var enemy_icon: AtlasTexture
var killed: int = 0
var common_drop_revealed: bool = false
var rare_drop_revealed: bool = false
const ENEMY_STATS_NODE_NAME: String = "EnemyStats"

const Stats = {
	NAME = "enemy_name",
	DESCRIPTION = "enemy_description",
	LV = "LV",
	HP = "HP",
	ATK = "ATK",
	DEF = "DEF",
	MND = "RES",
	EXP = "EXP",
	WEAKNESSES = "weaknesses",
	TOLERANCES = "tolerances",
	COMMON_DROP_ID = "common_drop_id",
	COMMON_DROP_RATE = "common_drop_rate",
	RARE_DROP_ID = "rare_drop_id",
	RARE_DROP_RATE = "rare_drop_rate"
}

func getStats() -> Dictionary:
	var info: SceneState = enemy_scene.get_state()
	var stats: Dictionary
	
	for stat in Stats.values():
		stats[stat] = 0
		
	for i in range(0, info.get_node_count()):
		var cur_node_name = info.get_node_name(i)
		if cur_node_name == ENEMY_STATS_NODE_NAME:
			for j in range(0, info.get_node_property_count(i)):
				stats[info.get_node_property_name(i, j)] = info.get_node_property_value(i, j)
			if stats[Stats.NAME] is String:
				stats[Stats.DESCRIPTION] = stats[Stats.NAME] + "_DESC"
			return stats
	
	printerr("No stats returned.")
	return stats
