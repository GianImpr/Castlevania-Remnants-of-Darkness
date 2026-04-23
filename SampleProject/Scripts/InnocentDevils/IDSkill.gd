extends Resource
class_name IDSkill

@export_category("General")
@export var name: String
@export_multiline var description: String
@export var cost: int
@export var power: int
@export var multiplier: float
@export var type: Type
@export var unlocked: bool
@export var learnable: bool = true
@export var learnable_by_evolution_ID: int ##Can only be learned by this specific Innocent Devil evolution. Check Evolutions enum in any of the InnocentDevil subclasses.
@export var AP_needed: int
@export_category("Synergy")
@export var synergy_engager: bool
@export var icon: CompressedTexture2D

enum Type {
	Physical,
	Magical,
	None
}
