extends Resource
class_name Legs

@export var legs_name: String
@export_multiline var legs_description: String
@export var element: Array[Global.Attribute]
@export var ATK: int
@export var DEF: int
@export var STR: int
@export var CON: int
@export var INT: int
@export var SYN: int
@export var RES: int
@export var LCK: int
@export var value: int
@export var max_quantity: int = 99
@export var icon: Texture2D
@export var recipe_status: RecipeStatus = RecipeStatus.UNAVAILABLE
@export var recipe: Array[Dictionary] = [{"id": 0, "quantity": 0, "inventory": Inventory.weapon}]

enum RecipeStatus {
	LOCKED,
	UNLOCKED,
	REVEALED,
	UNAVAILABLE
}

enum Inventory {
	weapon,
	headgear,
	body,
	item,
	legs
}


enum Leg {
	SANDALS,
	WINGTIPS,
	ENGINEER_BOOTS,
	ALUMINUM_LEGGINGS,
	FEATHER_BOOTS
}
