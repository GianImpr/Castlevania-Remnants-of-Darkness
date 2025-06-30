## Used to communicate to the level capture scene the levels to capture by Levelshot
@tool
class_name LevelshotCaptureData
extends Resource


const DATA_FILE_PATH = "user://levelshot_capture_data.tres"


@export var level_scene_paths:Array[String] = []


static func save(p_level_scene_paths:Array[String]) -> bool:
	var data := LevelshotCaptureData.new()
	data.level_scene_paths = p_level_scene_paths
	var result := ResourceSaver.save(data, DATA_FILE_PATH)
	if result != OK:
		printerr("LevelshotCaptureData: could not save data : %s" % error_string(result))
		return false
	return true


static func load() -> LevelshotCaptureData:
	return ResourceLoader.load(DATA_FILE_PATH) as LevelshotCaptureData
