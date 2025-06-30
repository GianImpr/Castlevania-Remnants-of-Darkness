class_name LevelshotLevelExtentBase
extends RefCounted


var _include_canvas_layer: bool
var _exclude_node_groups:Array[String] = []


func get_level_extents(level_node: Node, include_canvas_layer: bool, exclude_node_groups: Array[String]) -> Array[Rect2]:
	_include_canvas_layer = include_canvas_layer
	_exclude_node_groups = exclude_node_groups
	return _get_level_extents(level_node)


func is_node_in_group(n: Node, node_groups: Array[String]) -> bool:
	for node_group in node_groups:
		if n.is_in_group(node_group):
			return true
	
	return false


func _get_level_extents(_level_node: Node) -> Array[Rect2]:
	var extents:Array[Rect2] = []
	return extents


func _is_node_skipped(n: Node) -> bool:
	n.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if is_node_in_group(n, _exclude_node_groups) and (n is CanvasItem or n is Control):
		n.visible = false
		return true
	
	if n is CanvasLayer and !n is ParallaxBackground and !_include_canvas_layer:
		n.visible = false
		return true

	if n is CanvasItem and !n.visible:
		return true
	
	if n is Camera2D:
		n.queue_free()
		return true

	return false
