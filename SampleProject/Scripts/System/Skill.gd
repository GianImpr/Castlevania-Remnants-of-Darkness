extends Resource
class_name Skill

@export var skill_name: String
@export_multiline var skill_description: String
@export var value: int
@export var max_quantity: int = 1
@export var type: SkillType
@export var cost_type: CostType
@export var cost_value: int
@export var command_input: Array[String]
@export var command_input_serialized: String
@export var icon: Texture2D
@export var weapon_type: Weapon.Type
@export var weapon_rank: WeaponRank
@export var transitions_into_state: String

enum SkillType {
	PICKABLE,
	ORB,
	LEARNABLE,
	OTHER
}

enum CostType {
	HP,
	MP,
	SP,
	FP,
	HEARTS
}

enum WeaponRank {
	E,
	D,
	C,
	B,
	A,
	S
}

enum Skills {
	FORTITUDE_GAUNTLET = 1,
	HOLY_MANUAL = 2,
	PLATINUM_ARM = 3,
	CYAN_ORB = 4,
	SWORD_SPIN = 5,
	AXE_THROW = 6,
	SWORD_HAND = 7,
	EXECUTIONERS_HAND = 8,
	BLACKSMITH_CONTRACT = 9,
	WARP_MEDALLION = 10,
	AWARENESS = 11,
	GUARD_STANCE = 12,
	WICKED_GLADIATOR_FIST = 13,
	STEADY_FIGHTER = 14,
	ELECTRIC_WICKED_GLADIATOR_FIST = 15,
	WIND_STORM = 16,
	TOME_OF_MONSTERS = 17,
	SHARP_EDGE = 18,
	CHARGE_ONE = 19
}
