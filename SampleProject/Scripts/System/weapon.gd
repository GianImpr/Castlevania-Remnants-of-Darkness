extends Resource
class_name Weapon

enum Type {
	SWORD = 0,
	GREATSWORD = 1,
	SPEAR = 3,
	FIST = 4,
	AXE = 2
}

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

enum Weapons {
	SHORT_SWORD,
	BULLOVA,
	CLAYMORE,
	FALCHION,
	MACE,
	BRONZE_SPEAR,
	PARTISAN
}

@export var weapon_name: String
@export_multiline var weapon_description: String
@export var type: Type
@export var element: Array[Global.Attribute]
@export var ATK: int
@export var DEF: int
@export var STR: int
@export var CON: int
@export var INT: int
@export var SYN: int
@export var RES: int
@export var LCK: int
@export var jump_cancel: bool
@export var crouch_attack: bool
@export var value: int
@export var max_quantity: int = 99
@export var icon: Texture2D
@export var sprite: PackedScene
@export var recipe_status: RecipeStatus = RecipeStatus.UNAVAILABLE
@export var recipe: Array[Dictionary] = [{"id": 0, "quantity": 0, "inventory": Inventory.weapon}]
