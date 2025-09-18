extends Resource
class_name InnocentDevilEntry

var id: int
var Name: String
var Stats: Dictionary #Current stats with boosts
var Growths: Dictionary #Total stat gains from level 1 to 99
var Boosts: Dictionary #Stat boosts to Hector
var Initial: Dictionary #Initial starting stats
var Bases: Dictionary = StaticGlobal.recursive_duplicate(Initial) #Current stats without boosts
var skills: Array[IDSkill]
var evo_crystals: Dictionary
var innocent_devil_scene: PackedScene

func getDataFromIDStats(devil: CharacterBody2D) -> void:
	var stats: InnocentDevilStats = devil.stats
	id = devil.id
	Name = devil.id_name
	Stats = StaticGlobal.recursive_duplicate(stats.Stats)
	Growths = StaticGlobal.recursive_duplicate(stats.Growths)
	Boosts = StaticGlobal.recursive_duplicate(stats.Boosts)
	Initial = StaticGlobal.recursive_duplicate(stats.Initial)
	Bases = StaticGlobal.recursive_duplicate(stats.Bases)
	skills = StaticGlobal.recursive_duplicate(stats.skills)
	evo_crystals = StaticGlobal.recursive_duplicate(stats.evo_crystals)
	innocent_devil_scene = load(devil.scene_file_path)
	
func applyStats(devil: CharacterBody2D) -> void:
	var stats: InnocentDevilStats = devil.stats
	devil.id = id
	devil.id_name = Name
	stats.Stats = StaticGlobal.recursive_duplicate(Stats)
	stats.Growths = StaticGlobal.recursive_duplicate(Growths)
	stats.Boosts = StaticGlobal.recursive_duplicate(Boosts)
	stats.Initial = StaticGlobal.recursive_duplicate(Initial)
	stats.Bases = StaticGlobal.recursive_duplicate(Bases)
	stats.skills = StaticGlobal.recursive_duplicate(skills)
	stats.evo_crystals = StaticGlobal.recursive_duplicate(evo_crystals)

func updateStats(devil: CharacterBody2D) -> void:
	getDataFromIDStats(devil)
