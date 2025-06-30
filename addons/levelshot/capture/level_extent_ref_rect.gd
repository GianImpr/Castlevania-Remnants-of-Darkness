class_name LevelshotLevelExtentFromRefRect
extends LevelshotLevelExtentBase


func _get_level_extents(level_node: Node) -> Array[Rect2]:
	var ref_rects:Array[Rect2] = []
	_get_level_extent_from_levelshot_ref_rects_rec(level_node, ref_rects)
	return ref_rects


func _get_level_extent_from_levelshot_ref_rects_rec(n: Node, ref_rects: Array[Rect2]) -> void:
	if _is_node_skipped(n):
		return

	if n is LevelshotBoundary:
		var rr: LevelshotBoundary = n
		ref_rects.append(rr.get_global_rect())
	
	for c in n.get_children():
		_get_level_extent_from_levelshot_ref_rects_rec(c, ref_rects)
