extends EditorExportPlugin

## Excludes Kanban Tasks from the exported project, since it's an editor-only
## plugin.
##
## To bypass this for the standalone export configure "kanban_tasks_standalone"
## as export feature.

func _get_name() -> String:
	# Plugins are processed in the order of their alphabetically sorted names.
	# We need this plugin to run before the GDScript export plugin runs.
	return "0_exclude_kanban_tasks"

var is_standalone_export: bool = false
var base_path: String = ""

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	is_standalone_export = features.has("kanban_tasks_standalone")
	# Assumption: Located in base folder of plugin.
	base_path = (get_script() as Script).resource_path.get_base_dir()

func _export_file(path: String, type: String, features: PackedStringArray) -> void:
	if is_standalone_export:
		return
	if path.begins_with(base_path):
		skip()
