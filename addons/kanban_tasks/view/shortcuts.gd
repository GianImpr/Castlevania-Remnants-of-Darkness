@tool
extends Node


var delete := Shortcut.new()
var duplicate := Shortcut.new()
var create := Shortcut.new()
var rename := Shortcut.new()
var search := Shortcut.new()
var confirm := Shortcut.new()
var undo := Shortcut.new()
var redo := Shortcut.new()

var save := Shortcut.new()
var save_as := Shortcut.new()


## Returns whether a specific node should handle the shortcut.
static func should_handle_shortcut(node: Node) -> bool:
	var focus_owner := node.get_viewport().gui_get_focus_owner()
	return focus_owner and (node.is_ancestor_of(focus_owner) or focus_owner == node)


func _ready() -> void:
	if Engine.is_editor_hint():
		# TODO: Update on editor settings change.
		__update_shortcuts_editor()
	else:
		__update_shortcuts_standalone()


func __update_shortcuts_editor() -> void:
	var editor_settings = Engine.get_singleton(&"EditorInterface").get_editor_settings()
	delete = editor_settings.get_shortcut("scene_tree/delete")
	duplicate = editor_settings.get_shortcut("scene_tree/duplicate")
	create = editor_settings.get_shortcut("scene_tree/add_child_node")
	rename = editor_settings.get_shortcut("scene_tree/rename")
	search = editor_settings.get_shortcut("editor/open_search")
	confirm = editor_settings.get_shortcut("ui_accept")
	undo = editor_settings.get_shortcut("ui_undo")
	redo = editor_settings.get_shortcut("ui_redo")


func __create(key: Key, shift: bool, ctrl: bool):
	var ev := InputEventKey.new()
	ev.command_or_control_autoremap = ctrl
	ev.shift_pressed = shift
	ev.keycode = key
	var shortcut := Shortcut.new()
	shortcut.events.append(ev)
	return shortcut


func __get(action: String, fallback: Shortcut = null) -> Shortcut:
	if InputMap.has_action(action):
		var shortcut := Shortcut.new()
		shortcut.events = InputMap.action_get_events(action)
		return shortcut
	return fallback


func __update_shortcuts_standalone() -> void:
	delete = __get("ui_kanban_delete", __get("ui_text_delete"))
	duplicate = __get("ui_kanban_duplicate", __get("ui_graph_duplicate"))
	create = __get("ui_kanban_create", __create(KEY_A, false, true))
	rename = __get("ui_kanban_rename", __create(KEY_F2, false, false))
	search = __get("ui_kanban_search", __get("ui_filedialog_find"))
	confirm = __get("ui_accept")
	undo = __get("ui_undo")
	redo = __get("ui_redo")
	
	save = __get("ui_kanban_save", __create(KEY_S, false, true))
	save_as = __get("ui_kanban_save_as", __create(KEY_S, true, true))
