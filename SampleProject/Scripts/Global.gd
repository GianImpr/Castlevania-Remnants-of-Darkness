extends Node
class_name StaticGlobal

static var player: HectorPlayer = null
static var game: Game = null
static var camera: GameCamera = null
static var item_box: ItemBox = null
static var enemy_box = null
static var tutorial_box: HintBox = null
static var description_box: HintBox = null
static var inventory = null
static var tutorial_screen: TutorialScreen = null
static var fade_screen: FadeScreen = null
static var total_fade_screen: TotalFadeScreen = null
static var dialogue_screen: DialogueBox = null
static var music_player: MusicPlayer = null
static var stage_presentation: StagePresentation = null
static var training_menu: TrainingMenu = null
static var game_over_screen: GameOverScreen = null
static var boss_bar = null
static var fps_display = null
static var settings_node: InvOptions = null
static var HUD: HeadsUpDisplay = null
static var minimap = null
var language: Languages = Languages.ENGLISH
var load_data: bool = false
var crazy_mode: bool = false
var loaded_settings: bool = false
static var screen = ScreenType.NONE
const TITLE_SCREEN_SCENE: String = "res://SampleProject/extra_scenes/title_screen.tscn"

var new_game_difficulty: Game.Difficulty
var new_game_player_name: String
var save_file_to_load: String
var save_destination: String

#Used in ChangeArea
@warning_ignore("unused_signal")
signal change_area(new_room, initial_position)

enum Languages {
	ENGLISH,
	ITALIAN,
	SPANISH,
	PORTUGUESE,
	FRENCH,
	DUTCH
}

const langs = ["en", "it", "es", "pt_BR", "fr", "nl"]


enum ScreenType {
	NONE,
	MENU,
	MAP,
	TRANSITION,
	TUTORIAL,
	EVENT,
	WHEEL,
	SHOP,
	TRAINING_MENU,
	TRAINING
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
	PARALYSIS = 13,
	ENFEEBLE = 14
}

func _ready() -> void:
	TranslationServer.set_locale(langs[language])

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
	
static func deep_dictionary_duplicate(value: Dictionary) -> Dictionary:
	var new_dict: Dictionary = {}
	for key in value.keys():
		new_dict[key] = value[key]
	return new_dict

static func recursive_duplicate(value: Variant, recursion_count: int = 0) -> Variant:
	const MAX_RECURSION: int = 100

	if value is Array:
		var array: Array = value
		var copy: Array = Array(
			[],
			array.get_typed_builtin(),
			array.get_typed_class_name(),
			array.get_typed_script(),
		)

		if recursion_count > MAX_RECURSION:
			push_error("Max recursion reached.")
			return copy
		recursion_count += 1

		for element: Variant in array:
			copy.append(recursive_duplicate(element, recursion_count))

		return copy

	if value is Dictionary:
		var dictionary: Dictionary = value
		var copy: Dictionary = {}

		if recursion_count > MAX_RECURSION:
			push_error("Max recursion reached.")
			return copy
		recursion_count += 1

		for key: Variant in dictionary:
			copy[recursive_duplicate(key, recursion_count)] \
					= recursive_duplicate(dictionary[key], recursion_count)

		return copy

	if value is Object:
		if recursion_count > MAX_RECURSION:
			push_error("Max recursion reached.")
			return null
		recursion_count += 1

		var object: Object = value

		if not is_instance_valid(object):
			return null # TODO `return object`?

		var object_class: StringName = object.get_class()

		if not ClassDB.can_instantiate(object_class):
			push_error('Cannot instantiate "%s".' % object_class)
			return null

		var copy: Object = ClassDB.instantiate(object_class)

		for property: Dictionary in object.get_property_list():
			var property_name: String = property.name
			var property_usage: int = property.usage

			# TODO: Check `PROPERTY_USAGE_ALWAYS_DUPLICATE`?
			if not (property_usage & PROPERTY_USAGE_STORAGE):    continue

			if property_usage & PROPERTY_USAGE_NEVER_DUPLICATE:
				copy.set(property_name, object.get(property_name))
			else:
				copy.set(
					property_name,
					recursive_duplicate(object.get(property_name), recursion_count),
				)

		return copy

	# `Packed*Array`s are pass-by-reference types, but they cannot contain
	# pass-by-reference elements, so we can use the standard method.
	if typeof(value) >= TYPE_PACKED_BYTE_ARRAY:
		@warning_ignore("unsafe_method_access")
		return value.duplicate()

	# A pass-by-value type.
	return value
