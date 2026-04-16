extends InnocentDevil
class_name Faerie

var funny_wall_destination: Vector2
var wall_event_id: int = 0

var current_evolution: Evolutions = Evolutions.INFANT_FAIRY
@export var evolutions: Array[Dictionary]

enum Evolutions {
	INFANT_FAIRY,
	LEAFFLE,
	HORNET
}

const EvolutionData = {
	NAME = "name",
	BODY = "sprite_body",
	CRYSTAL = "sprite_crystal",
	WINGS = "sprite_wings",
	SMEAR = "sprite_smear",
	IMAGE = "image"
}

func _ready() -> void:
	can_change_mode = false
	Global.HUD.id_mode.self_modulate = Global.HUD.ID_NO_MODE_COLOR

func updateCurSkillTransition() -> void:
	match current_skill:
		_:
			skill_transitions_to_state = "healing"
