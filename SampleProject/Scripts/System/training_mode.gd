extends Resource
class_name TrainingMode

@export_category("Training Info")
@export var title: String
@export_multiline var description: String
@export_multiline var challenge_beginner: String
@export_multiline var challenge_intermediate: String
@export_multiline var challenge_advanced: String
@export var icon: CompressedTexture2D
@export_category("Training Rules")
@export var enemies_beginner: Array[PackedScene]
@export var enemies_intermediate: Array[PackedScene]
@export var enemies_advanced: Array[PackedScene]
@export var can_deal_damage: bool = false
@export var remove_MP: bool = true
@export var remove_hearts: bool = true
@export_range(1, 100, 1, "suffix:% HP") var damage_upon_hit: int
@export_range(1, 100, 1) var hearts_to_collect: int
@export_range(1, 5, 0.1) var heart_level_multiplier: float = 1
var max_challenge_level: TrainingLevel = TrainingLevel.BEGINNER

enum TrainingLevel {
	BEGINNER,
	INTERMEDIATE,
	ADVANCED,
	COMPLETE
}

enum Training {
	NONE,
	GUARD,
	PERFECT_GUARD,
	QUICK_RECOVER,
	QUICK_GUARD,
	CHAIN_GUARD,
	JUMP_CANCEL,
	BACKDASH_CANCEL
}
