@tool
class_name LevelshotMgmt
extends PanelContainer


const CAPTURE_SCENE = "res://addons/levelshot/capture/level_shot_capture.tscn"


@onready var _levels_tree := %LevelshotLevelsTree
@onready var _level_settings := %LevelSettings
@onready var _none_selected := %NoLevelSelectedCenterContainer
@onready var _version_lbl := %VersionLabel


func _ready() -> void:
	_update_version_label()


func _update_version_label() -> void:
	var config := ConfigFile.new()
	if OK != config.load("res://addons/levelshot/plugin.cfg"):
		printerr("LevelshotMgmt: could not open plugin file to get version")
		return
	var version:String = config.get_value("plugin", "version", "")
	if version == "":
		printerr("LevelshotMgmt: could not get version from config file")
		return
	_version_lbl.text = "v%s" % version


func _on_add_level_btn_pressed() -> void:
	_levels_tree.add_new()


func _on_levelshot_levels_tree_level_selected(data: LevelshotLevelData) -> void:
	if !data:
		_level_settings.visible = false
		_none_selected.visible = true
		return
	_level_settings.visible = true
	_none_selected.visible = false
	_level_settings.edit(data)


func _on_capture_all_btn_pressed() -> void:
	var selected_level_paths :Array[String] = _levels_tree.get_selected_levels()
	if !selected_level_paths: return
	_level_settings.update_data()
	if !LevelshotCaptureData.save(selected_level_paths): return
	if Engine.is_editor_hint(): EditorInterface.play_custom_scene(CAPTURE_SCENE)


func save() -> void:
	_levels_tree.save()


func _on_level_settings_capture_level(level_scene_path: String) -> void:
	if level_scene_path.is_empty(): return
	_level_settings.update_data()
	var selected_level_paths :Array[String] = [level_scene_path]
	if !LevelshotCaptureData.save(selected_level_paths): return
	if Engine.is_editor_hint(): EditorInterface.play_custom_scene(CAPTURE_SCENE)
