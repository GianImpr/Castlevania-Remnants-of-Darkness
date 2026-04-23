extends InnocentDevil
class_name Faerie

var funny_wall_destination: Vector2
var wall_event_id: int = 0

var current_evolution: Evolutions = Evolutions.INFANT_FAIRY
@export var evolutions: Array[Dictionary]
@export var smear_sprite: Sprite2D
@export var wings: Sprite2D
@export var crystal: Sprite2D
var detected_enemies: Array[Enemy]
var targeted_enemy: Enemy

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
		Ability.POISON_POWDER:
			lock_current_skill = true
			skill_transitions_to_state = "powder"
		_:
			skill_transitions_to_state = "healing"
			
func updateSpriteToCurrentEvolution() -> void:
	sprite.texture = evolutions[current_evolution][EvolutionData.BODY]
	wings.texture = evolutions[current_evolution][EvolutionData.WINGS]
	crystal.texture = evolutions[current_evolution][EvolutionData.CRYSTAL]
	smear_sprite.texture = evolutions[current_evolution][EvolutionData.SMEAR]

func onEnemyDetected(body: Node2D) -> void:
	if not body is Enemy:
		return
	detected_enemies.append(body)
	targetEnemy()
	
func onEnemyLost(body: Node2D) -> void:
	if not body is Enemy:
		return
	detected_enemies.erase(body)
	targetEnemy()

func targetEnemy() -> void:
	for enemy: Enemy in detected_enemies:
		if not targeted_enemy:
			targeted_enemy = enemy
			continue
			
		if Global.Attribute.POISON in enemy.stats.weaknesses:
			targeted_enemy = enemy
			return

func healingGrunt() -> void:
	var voice_id: int = randi_range(1, 2)
	match current_evolution:
		Evolutions.INFANT_FAIRY:
			voice.play_sound_effect_from_library("infant_heal_" + str(voice_id))
		_:
			voice.play_sound_effect_from_library("second_tier_" + str(voice_id))
			
func attackGrunt() -> void:
	match current_evolution:
		_:
			voice.play_sound_effect_from_library("leaffle_attack")

func playVoice() -> void:
	if current_skill == Ability.POISON_POWDER:
		attackGrunt()
	else:
		healingGrunt()
