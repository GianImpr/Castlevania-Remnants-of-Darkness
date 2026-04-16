extends Resource
class_name InnocentDevilEntry

var id: int
var Name: String
var is_alive: bool
var allow_evo_crystals: bool
var Stats: Dictionary #Current stats with boosts
var Growths: Dictionary #Total stat gains from level 1 to 99
var Boosts: Dictionary #Stat boosts to Hector
var Initial: Dictionary #Initial starting stats
var Bases: Dictionary = StaticGlobal.deep_dictionary_duplicate(Initial) #Current stats without boosts
var skills: Array[IDSkill]
var evo_crystals: Array[int]
var current_evolution: int
var innocent_devil_scene: PackedScene
var image: CompressedTexture2D
var evolution_name: String

func getDataFromIDStats(devil: InnocentDevil) -> void:
	var stats: InnocentDevilStats = devil.stats
	is_alive = devil.is_alive
	allow_evo_crystals = devil.allow_evo_crystals
	id = devil.id
	Name = devil.id_name
	image = devil.evolutions[devil.current_evolution][devil.EvolutionData.IMAGE]
	evolution_name = devil.evolutions[devil.current_evolution][devil.EvolutionData.NAME]
	Stats = StaticGlobal.deep_dictionary_duplicate(stats.Stats)
	Growths = StaticGlobal.deep_dictionary_duplicate(stats.Growths)
	Boosts = StaticGlobal.deep_dictionary_duplicate(stats.Boosts)
	Initial = StaticGlobal.deep_dictionary_duplicate(stats.Initial)
	Bases = StaticGlobal.deep_dictionary_duplicate(stats.Bases)
	skills = StaticGlobal.recursive_duplicate(stats.skills)
	evo_crystals = stats.evo_crystals.duplicate(true)
	current_evolution = devil.current_evolution
	innocent_devil_scene = load(devil.scene_file_path)
	
func applyStats(devil: InnocentDevil) -> void:
	var stats: InnocentDevilStats = devil.stats
	devil.is_alive = is_alive
	devil.allow_evo_crystals = allow_evo_crystals
	devil.id = id
	devil.id_name = Name
	devil.current_evolution = current_evolution
	stats.Stats = StaticGlobal.deep_dictionary_duplicate(Stats)
	stats.Growths = StaticGlobal.deep_dictionary_duplicate(Growths)
	stats.Boosts = StaticGlobal.deep_dictionary_duplicate(Boosts)
	stats.Initial = StaticGlobal.deep_dictionary_duplicate(Initial)
	stats.Bases = StaticGlobal.deep_dictionary_duplicate(Bases)
	stats.skills = StaticGlobal.recursive_duplicate(skills)
	stats.evo_crystals = evo_crystals.duplicate(true)

func updateStats(devil: InnocentDevil) -> void:
	getDataFromIDStats(devil)
