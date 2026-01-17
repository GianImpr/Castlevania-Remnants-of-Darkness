extends Resource
class_name Headgear

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

enum Headgears {
	LEATHER_HAT,
	CIRCLET,
	SUNGLASSES,
	THICK_GLASSES,
	RIBBON,
	GLASSES,
	FEDORA,
	VELVET_HAT,
	PROTECTIVE_HELM,
	SILK_HAT,
	MONOCLE,
	CEREMONIAL_MASK,
	IRON_HELM,
	BANDANA,
	COMMANDERS_HAT,
	TRAVELERS_HAT,
	FESTIVAL_MASK,
	VIKINGS_HAT,
	STEEL_HELM,
	NOBUNAGAS_HELM,
	SKULL_MASK,
	SAMURAIS_HELM,
	BELMONTS_BANDANA,
	BLOODY_GOGGLES,
	DRAGON_HELM,
	ROYAL_CROWN,
	ATTICA_HELMET,
	IMPERVIOUS_HELMET
}



@export var headgear_name: String
@export_multiline var headgear_description: String
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
