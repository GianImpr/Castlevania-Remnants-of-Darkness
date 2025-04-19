extends Node
class_name InnocentDevilStats

@export var Stats: Dictionary #Current stats with boosts
@export var Growths: Dictionary #Total stat gains from level 1 to 99
@export var Boosts: Dictionary #Stat boosts to Hector
@export var Initial: Dictionary #Initial starting stats
@export var Bases: Dictionary = Initial.duplicate(true) #Current stats without boosts
@export var skills: Array[IDSkill]
@export var evo_crystals: Dictionary
@export var level_up: GPUParticles2D
@export var sound: PolyphonicAudio

func levelUp():
	while Stats["EXP"] >= expNeededToLvUp():
		Stats["LV"] += 1
		for stat in ["MHearts", "ATK", "DEF", "INT", "MND"]:
			Bases[stat] = Initial[stat] + int(Growths[stat]/100.0*(Stats["LV"]))
			Stats[stat] = Bases[stat]
	level_up.emitting = true
	Global.HUD.id_level_up_animation.play("level_up")
	sound.play_sound_effect_from_library("level_up")
	
func expNeededToLvUp() -> int:
	return (13*pow(Stats["LV"], 3)+39*pow(Stats["LV"], 2)+104*Stats["LV"]+100)/6
