@tool
class_name LevelshotLevelsTree
extends Tree


signal level_selected(data:LevelshotLevelData)


const REMOVE_ICON = preload("res://addons/levelshot/assets/icons/Remove.svg")


enum Columns {
	SELECTED,
	PATH,
	REMOVE_BTN,
}


@onready var _levels_file_dlg := $LevelsFileDialog


var _level_shot_data:LevelshotData
var _selected_level_shot_level_data:LevelshotLevelData
var _root:TreeItem


func _ready() -> void:
	_level_shot_data = LevelshotData.load()
	set_column_expand(Columns.SELECTED, false)
	set_column_expand(Columns.REMOVE_BTN, false)
	_refresh()
	_select_first.call_deferred()
	if Engine.is_editor_hint(): _monitor_file_sys_dock_events.call_deferred()


func _select_first() -> void:
	if !_level_shot_data.levels: return
	var data := _root.get_child(0).get_metadata(Columns.SELECTED) as LevelshotLevelData
	_select_level(data.level_scene_path)
	

func add_new() -> void:
	_levels_file_dlg.popup_centered()
	_levels_file_dlg.invalidate()


func _get_path_for_sorting(path:String) -> String:
	var temp := ""
	var number := ""
	for i in path.length():
		var c := path[i]
		if c.is_valid_int():
			number += c
		else:
			if number:
				temp += "%06d" % int(number)
				number = ""
			temp += c
	
	if number:
		temp += "%06d" % int(number)
	
	return temp

func _sort_path(a:Variant, b:Variant) -> bool:
	var s1 := _get_path_for_sorting(var_to_str(a))
	var s2 := _get_path_for_sorting(var_to_str(b))
	return s1 < s2


func _get_sorted_scene_paths() -> Array[String]:
	var paths:Array[String] = []
	for level in _level_shot_data.levels:
		paths.append(level.level_scene_path)
	paths.sort_custom(_sort_path)
	return paths


func _refresh() -> void:
	clear()
	_root = create_item()
	var sorted_scene_paths := _get_sorted_scene_paths()
	for scene_path in sorted_scene_paths:
		var data := _level_shot_data.get_level_shot_level_data(scene_path)
		var item := create_item(_root)
		
		if !data.is_default:
			item.set_cell_mode(Columns.SELECTED,TreeItem.CELL_MODE_CHECK)
			item.set_checked(Columns.SELECTED, data.selected)
			item.set_editable(Columns.SELECTED, true)

		item.set_text(Columns.PATH, data.get_display_name(true))
		if !data.is_default:
			item.set_tooltip_text(Columns.PATH, data.level_scene_path + "\n(double click to open)")
			item.add_button(Columns.REMOVE_BTN, REMOVE_ICON, 0, false, "Remove %s" % data.level_scene_path)
		item.set_metadata(Columns.SELECTED, data)


func _select_level(level_scene_path: String) -> void:
	_selected_level_shot_level_data = _level_shot_data.get_level_shot_level_data(level_scene_path)
	for item in _root.get_children():
		var data := item.get_metadata(Columns.SELECTED) as LevelshotLevelData
		if data.level_scene_path == level_scene_path:
			set_selected(item, Columns.SELECTED)
			_selected_level_shot_level_data = data


func _on_levels_file_dialog_files_selected(paths: PackedStringArray) -> void:
	var data:LevelshotLevelData
	for path in paths:
		if _level_shot_data.get_level_shot_level_data(path): continue
		data = LevelshotLevelData.create(path)
		_level_shot_data.levels.append(data)
	if !data: return
	_level_shot_data.save()
	_refresh()
	_select_level(data.level_scene_path)


func _on_button_clicked(item: TreeItem, _column: int, _id: int, _mouse_button_index: int) -> void:
	var data := item.get_metadata(Columns.SELECTED) as LevelshotLevelData
	var index := _level_shot_data.levels.find(data)
	_level_shot_data.levels.remove_at(index)
	_refresh()
	if data != _selected_level_shot_level_data and _selected_level_shot_level_data:
		_select_level(_selected_level_shot_level_data.level_scene_path)
	elif _root.get_child_count() == 0:
		_selected_level_shot_level_data = null
		level_selected.emit(null)
	else:
		data = _root.get_child(0).get_metadata(Columns.SELECTED) as LevelshotLevelData
		_select_level(data.level_scene_path)


func _on_item_selected() -> void:
	var item := get_selected()
	var data := item.get_metadata(Columns.SELECTED) as LevelshotLevelData
	_selected_level_shot_level_data = data
	level_selected.emit(data)
	_level_shot_data.save()


func _on_item_edited() -> void:
	var item := get_selected()
	var data := item.get_metadata(Columns.SELECTED) as LevelshotLevelData
	var selected := item.is_checked(Columns.SELECTED)
	if data.selected == selected: return
	data.selected = selected
	## save


func get_selected_levels() -> Array[String]:
	var selected_levels:Array[String] = []
	for level in _level_shot_data.levels:
		if level.selected and !level.is_default:
			selected_levels.append(level.level_scene_path)
	
	return selected_levels


func get_current_selected_level() -> String:
	if !_selected_level_shot_level_data: return ""
	return _selected_level_shot_level_data.level_scene_path


func save() -> void:
	_level_shot_data.save()


func _on_gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if !mb or !mb.double_click or mb.button_index != MOUSE_BUTTON_LEFT: return
	var pos := mb.global_position - global_position
	var item := get_item_at_position(pos)
	if !item: return
	var data := item.get_metadata(Columns.SELECTED) as LevelshotLevelData
	EditorInterface.open_scene_from_path(data.level_scene_path)


func _monitor_file_sys_dock_events() -> void:
	var file_dock := EditorInterface.get_file_system_dock()
	file_dock.files_moved.connect(_on_file_moved)
	file_dock.file_removed.connect(_on_file_removed)


func _on_file_removed(file:String) -> void:
	var data := _level_shot_data.get_level_shot_level_data(file)
	if data:
		var index := _level_shot_data.levels.find(data)
		_level_shot_data.levels.remove_at(index)
	else:
		data = _level_shot_data.find_level_shot_level_data_with_capture_script(file)
		if data:
			data.levelshot_capture_plugin = ""
		else:
			return
	_level_shot_data.save()
	_refresh()


func _on_file_moved(old_file:String, new_file:String) -> void:
	var data := _level_shot_data.get_level_shot_level_data(old_file)
	if data:
		data.level_scene_path = new_file
	else:
		data = _level_shot_data.find_level_shot_level_data_with_capture_script(old_file)
		if data:
			data.levelshot_capture_plugin = new_file
		else:
			return
	_level_shot_data.save()
	_refresh()
