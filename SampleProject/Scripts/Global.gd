extends Node

static var player = null
static var game: Game = null
static var camera: Camera2D = null
static var item_box = null
static var enemy_box = null
static var tutorial_box = null
static var inventory = null
static var tutorial_screen: TutorialScreen = null
static var fade_screen = null
static var music_player: PolyphonicMenuAudio = null
static var stage_presentation = null
static var boss_bar = null
static var fps_display = null
static var settings_node: InvOptions = null
static var HUD = null
var load_data: bool = false
var crazy_mode: bool = false
var loaded_settings: bool = false
static var screen = ScreenType.NONE
const TITLE_SCREEN_SCENE: String = "res://SampleProject/extra_scenes/title_screen.tscn"


enum ScreenType {
	NONE,
	MENU,
	MAP,
	TRANSITION,
	TUTORIAL,
	EVENT
}
enum Attribute {
	NONE = 0,
	HIT = 1,
	SLASH = 2,
	FIRE = 3,
	ICE = 4,
	THUNDER = 5,
	WIND = 6,
	EARTH = 7,
	LIGHT = 8,
	DARK = 9,
	POISON = 10,
	CURSE = 11,
	STONE = 12,
	PARALYSIS = 13
}

func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and game != null and not loaded_settings:
		loaded_settings = true
		settings_node.triggerSettings()

func getStat(stat: String):
	return player.stats.Stats[stat]
	
func getBasicStats():
	var stats: Array[int]
	var stat_names = ["STR", "CON", "INT", "RES", "SYN", "LCK"]
	for stat in stat_names:
		stats.append(getStat(stat))
	return stats

func toTitleScreen() -> void:
	get_tree().paused = true
	get_tree().change_scene_to_file.call_deferred(TITLE_SCREEN_SCENE)
	loaded_settings = false
	game = null
	player = null
	camera = null
	item_box = null
	enemy_box = null
	tutorial_box = null
	tutorial_screen = null
	inventory = null
	fade_screen = null
	music_player = null
	stage_presentation = null
	boss_bar = null
	fps_display = null
	settings_node = null
	stage_presentation = null
	HUD = null
