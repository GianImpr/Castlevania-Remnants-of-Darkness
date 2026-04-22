extends InnocentDevil
class_name Faerie

var funny_wall_destination: Vector2
var wall_event_id: int = 0

var current_evolution: Evolutions = Evolutions.INFANT_FAIRY
@export var evolutions: Array[Dictionary]
@export var smear_sprite: Sprite2D
@export var wings: Sprite2D
@export var crystal: Sprite2D

enum Evolutions {
	INFANT_FAIRY,
	HORNET,
	LEAFFLE
}

const EvolutionData = {
	NAME = "name",
	BODY = "sprite_body",
	CRYSTAL = "sprite_crystal",
	WINGS = "sprite_wings",
	SMEAR = "sprite_smear",
	IMAGE = "image",
	EVO_CRYSTALS_ACCEPTED = "evo_type",
	EVO_CRYSTALS_REQUIRED = "evo_quantity"
}

func _ready() -> void:
	super()
	can_change_mode = false
	Global.HUD.id_mode.self_modulate = Global.HUD.ID_NO_MODE_COLOR

func updateCurSkillTransition() -> void:
	match current_skill:
		_:
			skill_transitions_to_state = "healing"
			
func updateSpriteToCurrentEvolution() -> void:
	sprite.texture = evolutions[current_evolution][EvolutionData.BODY]
	wings.texture = evolutions[current_evolution][EvolutionData.WINGS]
	crystal.texture = evolutions[current_evolution][EvolutionData.CRYSTAL]
	smear_sprite.texture = evolutions[current_evolution][EvolutionData.SMEAR]
