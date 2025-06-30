@tool
extends EditorPlugin


const MAIN_SCENE = preload("res://addons/levelshot/ui/level_shot_mgmt.tscn")
const PLUGIN_ICON = preload("res://addons/levelshot/assets/icons/Camera.svg")


var _main_scene: LevelshotMgmt


func _enter_tree() -> void:
	# force addition of settings
	LevelshotProjectSettings.get_img_save_folder()
	
	_main_scene = MAIN_SCENE.instantiate()
	EditorInterface.get_editor_main_screen().add_child(_main_scene)
	_make_visible(false)


func _exit_tree() -> void:
	if _main_scene:
		_main_scene.queue_free()
		_main_scene = null


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if _main_scene:
		_main_scene.visible = visible


func _get_plugin_name() -> String:
	return "Levelshot"


func _get_plugin_icon() -> Texture2D:
	return PLUGIN_ICON


func _apply_changes() -> void:
	if _main_scene:
		_main_scene.save()
