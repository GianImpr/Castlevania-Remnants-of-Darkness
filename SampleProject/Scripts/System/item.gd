extends Resource
class_name Item

enum Type {
	COLLECTIBLE = 0,
	CONSUMABLE = 1,
	RARE = 2,
	MATERIAL = 3
}
enum HealingType {
	NONE = 0,
	HEALTH = 1,
	MAGIC = 2,
	SYNERGY = 3,
	TRANSFORMATION = 4,
	HEART = 5,
	POISON = 6,
	CURSE = 7,
	REVIVE = 8
}

@export var item_name: String
@export var item_description: String
@export var type: Type
@export var healing_type: HealingType
@export var power: int
@export var value: int
@export var max_quantity: int
@export var icon: Texture2D
