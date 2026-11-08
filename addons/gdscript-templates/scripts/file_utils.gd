@tool
extends Object

const Debug = preload("res://addons/gdscript-templates/scripts/debug_utils.gd")

static func load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var content = FileAccess.get_file_as_string(path)
	var json = JSON.new()
	if json.parse(content) != OK:
		push_warning("GDScript Templates: can't parse %s (line %d): %s" % [path, json.get_error_line(), json.get_error_message()])
		return {}

	var data = json.get_data()
	if not data is Dictionary:
		push_warning("GDScript Templates: %s must contain a JSON object" % path)
		return {}

	Debug.info("✓ %s loaded!" % path)
	return data

static func save_json_file(data: Dictionary, path: String) -> bool:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())

	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("GDScript Templates: can't write %s (%s)" % [path, error_string(FileAccess.get_open_error())])
		return false

	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	Debug.info("✓ %s saved!" % path)
	return true
