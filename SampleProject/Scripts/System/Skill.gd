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
