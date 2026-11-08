@tool
extends Control

@export var filter_type: StringName

@onready var icon: TextureRect = $Icon
@onready var path: LineEdit = $Path

var value: String:
	set(t):
		path.text = t
		update_object()
	get:
		return path.text

var base_node: Node:
	set(bn):
		base_node = bn
		update_object()

var object: Object
var update_queued: bool

signal object_changed

func _ready() -> void:
	if is_part_of_edited_scene():
		return
	
	update_object()
	path.set_drag_forwarding(Callable(), can_drop_node, drop_node)

func update_object():
	if update_queued:
		return
	
	update_queued = true
	_update_object.call_deferred()

func _update_object():
	update_queued = false
	
	if base_node and not value.is_empty():
		if value.contains(":"):
			object = TweenAnimation.TweenerAnimator.get_target_object(base_node, value)
		else:
			object = base_node.get_node_or_null(value)
	else:
		object = null
	
	object_changed.emit()
	
	if object:
		if object is TweenNode:
			icon.texture = load("uid://4yavgmppmd22")
		else:
			icon.texture = EditorInterface.get_editor_theme().get_icon(object.get_class(), &"EditorIcons")
		
		if validate_type(object):
			path.modulate = Color.WHITE
		else:
			path.modulate = Color.RED
		
		if object is Node:
			icon.tooltip_text = object.name
		else:
			icon.tooltip_text = object.to_string()
	else:
		icon.texture = EditorInterface.get_editor_theme().get_icon(&"MissingNode", &"EditorIcons")
		icon.tooltip_text = ""
		path.modulate = Color.RED

func validate_type(object: Object) -> bool:
	if filter_type.is_empty():
		return true
	
	if object.get_class() == filter_type:
		return true
	
	var scr: Script = object.get_script()
	if scr and scr.get_global_name() == filter_type:
		return true
	
	return false

func can_drop_node(pos: Vector2, data: Variant) -> bool:
	var root := EditorInterface.get_edited_scene_root()
	if not root:
		return false
	
	if data.get("type", "") != "nodes":
		return false
	
	var paths: Array = data.get("nodes", [])
	if paths.size() != 1:
		return false
	
	var node: Node = get_tree().root.get_node(paths[0])
	if not root.is_ancestor_of(node):
		return false
	
	if not validate_type(node):
		return false
	
	return true

func drop_node(pos: Vector2, data: Variant):
	var node: Node = get_tree().root.get_node(data["nodes"][0])
	value = base_node.get_path_to(node)

func pick_node() -> void:
	if filter_type.is_empty():
		EditorInterface.popup_node_selector(node_picked, [], object as Node)
	else:
		EditorInterface.popup_node_selector(node_picked, [filter_type], object as Node)

func node_picked(path: NodePath):
	var node := get_tree().edited_scene_root.get_node_or_null(path)
	if node:
		value = base_node.get_path_to(node)
