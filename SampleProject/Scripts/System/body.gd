extends Resource
class_name Body

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

enum Bodies {
	CASUAL_CLOTHES,
	HOBOS_CLOTHES,
	LEATHER_ARMOR,
	BRONZE_CUIRASS,
	IRON_PLATE,
	SCALE_MAIL,
	BREASTPLATE,
	PONCHO,
	STEEL_MAIL,
	SURCOAT,
	CHAIN_MAIL,
	SERENITY_ROBE
}


@export var body_name: String
@export_multiline var body_description: String
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
