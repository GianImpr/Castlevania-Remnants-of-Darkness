extends Node
class_name InnocentDevilStats

@export var Stats: Dictionary #Current stats with boosts
@export var Growths: Dictionary #Total stat gains from level 1 to 99
@export var Boosts: Dictionary #Stat boosts to Hector
@export var Initial: Dictionary #Initial starting stats
@export var Bases: Dictionary #Current stats without boosts
@export var skills: Array[IDSkill]
@export var evo_crystals: Array[int]
@export var level_up: CPUParticles2D
@export var sound: PolyphonicAudio
@export var sprite: Sprite2D
@export var effects: Node2D

enum EVO_CRYSTAL {
	RED,
	BLUE,
	GREEN,
	YELLOW,
	WHITE
}

func _ready() -> void:
	Initial.make_read_only()
	if Bases.size() == 0:
		Bases = StaticGlobal.deep_dictionary_duplicate(Initial)
		Stats = StaticGlobal.deep_dictionary_duplicate(Initial)

func levelUp():
	while Stats["EXP"] >= expNeededToLvUp():
		Stats["LV"] += 1
		for stat in ["MHearts", "ATK", "DEF", "INT", "MND"]:
			Bases[stat] = Initial[stat] + int(Growths[stat]/100.0*(Stats["LV"]))
			Stats[stat] = Bases[stat]
	level_up.emitting = true
	StaticGlobal.HUD.id_level_up_animation.play("level_up")
	sound.play_sound_effect_from_library("level_up")
	
func expNeededToLvUp() -> int:
	return (13*pow(Stats["LV"], 3)+39*pow(Stats["LV"], 2)+104*Stats["LV"]+100)/6
	
func isGuarding() -> bool:
	return get_parent().isGuarding()
	
func applyHitEffect(type: Global.Attribute) -> void:
	if type != Global.Attribute.NONE and type != Global.Attribute.SLASH and type != Global.Attribute.HIT and type != Global.Attribute.STONE and type != Global.Attribute.CURSE and type != Global.Attribute.POISON and type != Global.Attribute.ENFEEBLE:
		effects.get_child(int(type)-3).emitting = true
	match type:
		Global.Attribute.FIRE:
			sound.play_sound_effect_from_library("hit_fire")
			#sprite.editShaderParams(0.2, 4, true, Color(0.766, 0, 0))
			sprite.self_modulate = Color(1, 0.674, 0.426)
		Global.Attribute.ICE:
			sound.play_sound_effect_from_library("hit_ice")
			#sprite.editShaderParams(0.2, 4, true, Color(0, 0, 1))
			sprite.self_modulate = Color(0, 0.639, 0.89)
		_:
			sound.play_sound_effect_from_library("damage")
			#sprite.editShaderParams(0.2, 4, true, Color(0.766, 0, 0))
			sprite.self_modulate = Color(1, 0, 0)

	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "self_modulate", Color(1,1,1), 0.1)

func calculateDamageTaken(base_power: int, multiplier: float, chip_damage: int, guard_break: bool, attribute: Global.Attribute, knockback: bool) -> int:
	var devil: InnocentDevil = get_parent()
	var damage = max((base_power - Stats["DEF"]/2)*multiplier, 1)
	var damage_with_chip = damage + chip_damage
	var guarding: bool = isGuarding()

	if guarding and not guard_break:
		if damage_with_chip < Stats["MHearts"]/10 and not guard_break:
			return 0
		elif damage_with_chip >= Stats["MHearts"]/10 and not guard_break:
			damage = min(damage * 0.1 + chip_damage, Stats["Hearts"]-1)
		get_parent().attack_blocked = true
	else:
		applyHitEffect(attribute)
	
	if guarding and Global.game.difficulty == Game.Difficulty.SIMPLIFIED:
		damage = 0
	
	return damage

## Learns a skill that can be unlocked.
func checkLearnedSkill() -> int:
	const MESSAGE_POPUP_DURATION: float = 3
	for i in range(0, skills.size()):
		var skill: IDSkill = skills[i]
		if skill.learnable and Stats["AP"] >= skill.AP_needed and not skill.unlocked and skill.learnable_by_evolution_ID == get_parent().current_evolution:
			skill.unlocked = true
			Global.tutorial_box.popup(get_parent().id_name + " learned [color=yellow]" + tr(skill.name) + "[/color].", MESSAGE_POPUP_DURATION)
	return -1
