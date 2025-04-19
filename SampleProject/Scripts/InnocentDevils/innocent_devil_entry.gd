extends Resource
class_name InnocentDevilEntry

var id: int
var Name: String
var Stats: Dictionary #Current stats with boosts
var Growths: Dictionary #Total stat gains from level 1 to 99
var Boosts: Dictionary #Stat boosts to Hector
var Initial: Dictionary #Initial starting stats
var Bases: Dictionary = Initial.duplicate(true) #Current stats without boosts
var skills: Array[IDSkill]
var evo_crystals: Dictionary
var innocent_devil_scene: PackedScene

func getDataFromIDStats(devil: CharacterBody2D) -> void:
	var stats: InnocentDevilStats = devil.stats
	id = devil.id
	Name = devil.id_name
	Stats = stats.Stats.duplicate(true)
	Growths = stats.Growths.duplicate(true)
	Boosts = stats.Boosts.duplicate(true)
	Initial = stats.Initial.duplicate(true)
	Bases = stats.Bases.duplicate(true)
	skills = stats.skills.duplicate(true)
	evo_crystals = stats.evo_crystals.duplicate(true)
	innocent_devil_scene = load(devil.scene_file_path)
	
func applyStats(devil: CharacterBody2D) -> void:
	var stats: InnocentDevilStats = devil.stats
	devil.id = id
	devil.id_name = Name
	stats.Stats = Stats.duplicate(true)
	stats.Growths = Growths.duplicate(true)
	stats.Boosts = Boosts.duplicate(true)
	stats.Initial = Initial.duplicate(true)
	stats.Bases = Bases.duplicate(true)
	stats.skills = skills.duplicate(true)
	stats.evo_crystals = evo_crystals.duplicate(true)

func updateStats(devil: CharacterBody2D) -> void:
	getDataFromIDStats(devil)
