## Levelshot configuration for levels you want to capture shots of
@tool
class_name LevelshotData
extends Resource

const _DATA_FILE_PATH = "res://addons/levelshot/config/levelshot_data.tres"

@export var levels:Array[LevelshotLevelData] = []


var _data_folder_checked := false


func _init() -> void:
	if !Engine.is_editor_hint(): return


func get_level_shot_level_data(level_scene_path:String) -> LevelshotLevelData:
	for level_shot_level_data in levels:
		if level_shot_level_data.level_scene_path == level_scene_path:
			return level_shot_level_data
	return null


func find_level_shot_level_data_with_capture_script(levelshot_capture_plugin:String) -> LevelshotLevelData:
	for level_shot_level_data in levels:
		if level_shot_level_data.levelshot_capture_plugin == levelshot_capture_plugin:
			return level_shot_level_data
	return null


static func load() -> LevelshotData:
	# create new resource and populate with default if it doesn't exist
	if !ResourceLoader.exists(_DATA_FILE_PATH):
		var new_data := LevelshotData.new()
		var default_level := LevelshotLevelData.new()
		default_level.is_default = true
		new_data.levels.append(default_level)
		new_data.save()
		return new_data
	
	var data:LevelshotData = ResourceLoader.load(_DATA_FILE_PATH)
	
	# remove an levels that don't exist
	var to_remove:Array[LevelshotLevelData] = []
	for level in data.levels:
		if !level.is_default and !ResourceLoader.exists(level.level_scene_path):
			to_remove.append(level)
	for level in to_remove:
		data.levels.erase(level)
	if to_remove: data.save()
	
	return data


func save() -> void:
	if !_data_folder_checked: _ensure_folder_exists(_DATA_FILE_PATH)
	ResourceSaver.save(self, _DATA_FILE_PATH)


func _ensure_folder_exists(data_file_path: String) -> void:
	_data_folder_checked = true
	var base_dir := data_file_path.get_base_dir()
	var d := DirAccess.open("res://")
	if d.dir_exists(base_dir):
		return
	d.make_dir_recursive(base_dir)
