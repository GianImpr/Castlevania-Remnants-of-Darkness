extends Resource
class_name Weapon

enum Type {
	SWORD = 0,
	FIST = 1,
	AXE = 2
}

@export var weapon_name: String
@export var weapon_description: String
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
