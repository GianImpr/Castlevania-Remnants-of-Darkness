extends Resource
class_name Skill

@export var skill_name: String
@export var skill_description: String
@export var value: int
@export var max_quantity: int = 1
@export var type: SkillType
@export var cost_type: CostType
@export var cost_value: int
@export var icon: Texture2D

enum SkillType {
	PICKABLE,
	LEARNABLE,
	SYNERGETIC,
	SPECIAL
}

enum CostType {
	HP,
	MP,
	SP,
	HEARTS
}
