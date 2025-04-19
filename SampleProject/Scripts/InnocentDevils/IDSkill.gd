extends Resource
class_name IDSkill

@export_category("General")
@export var name: String
@export_multiline var description: String
@export var cost: int
@export var power: int
@export var multiplier: float
@export var type: Type
@export_category("Synergy")
@export var synergy_engager: bool
@export var icon: CompressedTexture2D

enum Type {
	Physical,
	Magical,
	None
}
