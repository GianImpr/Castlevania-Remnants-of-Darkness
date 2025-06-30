@tool
class_name LevelshotLevelSettings
extends MarginContainer


signal capture_level(level_scene_path:String)


const SCALE_HELPER_TEXT_STRING_FORMAT = "(image will be %s%% of level size)"


@onready var _file_path_lbl := %FilePathsLabel
@onready var _mirror_default_cb:CheckBox = %MirrorDefaultCheckBox
# image size
@onready var _image_size_scale_cb:CheckBox = %SizeOptionScaleCheckBox
@onready var _image_size_max_size_cb:CheckBox = %SizeOptionMaxCheckBox
@onready var _image_size_scale_with_max_size_cb:CheckBox = %ScaleWithMaxCheckBox
@onready var _scale:SpinBox = %ScaleSpinBox
@onready var _scale_helper_lbl:Label = %ScaleHelperLabel
@onready var _size_x:SpinBox = %SizeXSpinBox
@onready var _size_y:SpinBox = %SizeYSpinBox
# level boundary
@onready var _level_extent_calc_cb:CheckBox = %LevelExtentsCalculateCheckBox
@onready var _level_extent_use_ref_rect_cb:CheckBox = %LevelExtentsLevelshotBoundaryCheckBox
@onready var _level_extent_both_cb:CheckBox = %LevelExtentsBothCheckBox
# other
@onready var _excluded_node_groups: LineEdit = %ExcludedNodeGroupsLineEdit
@onready var _include_canvas_layers: CheckBox = %IncludeCanvasLayersCheckBox
@onready var _capture_btn := %CaptureCurrentLevelBtn
@onready var _pause_before_capture:SpinBox = %PauseBeforeCaptureSpinBox
@onready var _capture_plugin_script:LineEdit = %CapturePluginScriptLineEdit
@onready var _select_capture_plugin_script_file_dlg := %SelectCapturePluginScriptFileDialog


var _current_data:LevelshotLevelData


func edit(level_data:LevelshotLevelData) -> void:
	update_data()
	_current_data = level_data
	if !level_data: return
	_file_path_lbl.text = "Scene File: %s" % level_data.get_display_name(false)
	if level_data.is_default:
		_mirror_default_cb.visible = false
		_on_mirror_default_check_box_toggled(false)
	else:
		_mirror_default_cb.visible = true
		#_mirror_default_cb.button_pressed = level_data.mirror_default
		_mirror_default_cb.set_pressed_no_signal(level_data.mirror_default)
		_on_mirror_default_check_box_toggled(level_data.mirror_default)
	_image_size_scale_cb.set_pressed_no_signal(level_data.image_size_option == LevelshotLevelData.ImageSizeOptions.SCALE)
	_image_size_max_size_cb.set_pressed_no_signal(level_data.image_size_option == LevelshotLevelData.ImageSizeOptions.MAXSIZE)
	_image_size_scale_with_max_size_cb.set_pressed_no_signal(level_data.image_size_option == LevelshotLevelData.ImageSizeOptions.SCALEWITHMAXSIZE)
	_scale.value = level_data.scale
	_on_scale_spin_box_value_changed(_scale.value)
	_size_x.value = level_data.size.x
	_size_y.value = level_data.size.y
	_level_extent_calc_cb.set_pressed_no_signal(level_data.level_boundary_option == LevelshotLevelData.LevelBoundaryOptions.CALCULATE)
	_level_extent_use_ref_rect_cb.set_pressed_no_signal(level_data.level_boundary_option == LevelshotLevelData.LevelBoundaryOptions.LEVELSHOTREFRECT)
	_level_extent_both_cb.set_pressed_no_signal(level_data.level_boundary_option == LevelshotLevelData.LevelBoundaryOptions.BOTH)
	_excluded_node_groups.text = level_data.excluded_node_groups
	_include_canvas_layers.set_pressed_no_signal(level_data.include_canvas_layers)
	_capture_btn.visible = !level_data.is_default
	_pause_before_capture.value = level_data.pause_before_capture_time
	_capture_plugin_script.text = level_data.levelshot_capture_plugin



func _on_scale_spin_box_value_changed(value: float) -> void:
	var percentage := int(100.0/float(value))
	_scale_helper_lbl.text = SCALE_HELPER_TEXT_STRING_FORMAT % percentage


func update_data() -> void:
	if _current_data == null:
		return
	if _image_size_scale_cb.button_pressed:
		_current_data.image_size_option = LevelshotLevelData.ImageSizeOptions.SCALE
	elif _image_size_max_size_cb.button_pressed:
		_current_data.image_size_option = LevelshotLevelData.ImageSizeOptions.MAXSIZE
	elif _image_size_scale_with_max_size_cb.button_pressed:
		_current_data.image_size_option = LevelshotLevelData.ImageSizeOptions.SCALEWITHMAXSIZE
	else:
		printerr("LevelSettingsControl: cannot set image size option!")
	_current_data.scale = int(_scale.value)
	_current_data.size.x = _size_x.value
	_current_data.size.y = _size_y.value
	if _level_extent_calc_cb.button_pressed:
		_current_data.level_boundary_option = LevelshotLevelData.LevelBoundaryOptions.CALCULATE
	elif _level_extent_use_ref_rect_cb.button_pressed:
		_current_data.level_boundary_option = LevelshotLevelData.LevelBoundaryOptions.LEVELSHOTREFRECT
	elif _level_extent_both_cb.button_pressed:
		_current_data.level_boundary_option = LevelshotLevelData.LevelBoundaryOptions.BOTH
	else:
		printerr("LevelSettingsControl: cannot set level boundary option!")
	_current_data.excluded_node_groups = _excluded_node_groups.text
	_current_data.include_canvas_layers = _include_canvas_layers.button_pressed
	_current_data.pause_before_capture_time = _pause_before_capture.value
	_current_data.levelshot_capture_plugin = _capture_plugin_script.text


func _on_mirror_default_check_box_toggled(toggled_on: bool) -> void:
	if !_current_data: return
	_current_data.mirror_default = toggled_on
	_image_size_scale_cb.disabled = toggled_on
	_image_size_max_size_cb.disabled = toggled_on
	_image_size_scale_with_max_size_cb.disabled = toggled_on
	_scale.editable = !toggled_on
	_size_x.editable = !toggled_on
	_size_y.editable = !toggled_on
	_level_extent_calc_cb.disabled = toggled_on
	_level_extent_use_ref_rect_cb.disabled = toggled_on
	_level_extent_both_cb.disabled = toggled_on
	_excluded_node_groups.editable = !toggled_on
	_include_canvas_layers.disabled = toggled_on
	_pause_before_capture.editable = !toggled_on
	_capture_plugin_script.editable = !toggled_on


func _on_capture_current_level_btn_pressed() -> void:
	capture_level.emit(_current_data.level_scene_path)


func _on_capture_plugin_script_open_file_btn_pressed() -> void:
	_select_capture_plugin_script_file_dlg.popup_centered()
	_select_capture_plugin_script_file_dlg.invalidate()


func _on_select_capture_plugin_script_file_dialog_file_selected(path: String) -> void:
	var temp := load(path) as Script
	if !temp:
		printerr("Selected script is invalid : %s" % path)
		return
	if temp.get_base_script() != LevelshotCapturePlugin:
		printerr("Selected script is not derrived from LevelshotCapturePlugin : %s" % path)
		return
	_capture_plugin_script.text = path
