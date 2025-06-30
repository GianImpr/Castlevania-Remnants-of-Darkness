## Levelshot configuration for a level you want to capture shots of
@tool
class_name LevelshotLevelData
extends Resource


enum ImageSizeOptions {
	SCALE,
	MAXSIZE,
	SCALEWITHMAXSIZE,
}


enum LevelBoundaryOptions {
	CALCULATE,
	LEVELSHOTREFRECT,
	BOTH,
}

@export var is_default : = false
@export var mirror_default := true
@export var level_scene_path := ""
@export var image_size_option:int = ImageSizeOptions.MAXSIZE
@export var scale := 10
@export var size := Vector2(1920, 1080)
@export var level_boundary_option:int = LevelBoundaryOptions.CALCULATE
@export var excluded_node_groups := "levelshot_exclude"
@export var include_canvas_layers := false
@export var selected := true
@export_file("*.gd") var levelshot_capture_plugin := ""
@export_range(0.0, 60.0) var pause_before_capture_time := 0.0


static func create(scene_path: String = "") -> LevelshotLevelData:
	var data := LevelshotLevelData.new()
	data.level_scene_path = scene_path
	data.mirror_default = true
	return data


func get_excluded_node_groups_array() -> Array[String]:
	var a :Array[String] = []
	
	for i in excluded_node_groups.split(","):
		a.append(i.lstrip(" ").rstrip(" "))
	
	return a


func get_display_name(short:bool) -> String:
	if is_default:
		return "Default Level Settings"
	if short:
		return level_scene_path.get_file()
	return level_scene_path
