extends Resource
class_name Accessory

@export var accessory_name: String
@export_multiline var accessory_description: String
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

enum Accessories {
	SCARF = 1,
	EMERALD_RING = 2,
	TALISMAN = 3,
	FORTITUDE_NECKLACE = 4,
	STUD_OF_CONCENTRATION = 5,
	BLACK_BELT = 6,
	BLOOD_CLOAK = 7,
	ADVENTURER_CLOAK = 8,
	WIZARD_CLOAK = 9,
	RED_SCARF = 10,
	RING_OF_LIFE = 11
}
