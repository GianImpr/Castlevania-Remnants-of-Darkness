class_name LevelshotLevelExtentCalculator
extends LevelshotLevelExtentBase


const ZERO_RECT = Rect2(Vector2.ZERO, Vector2.ZERO)


func _get_level_extents(level_node: Node) -> Array[Rect2]:
	var extents:Array[Rect2] = [_get_node_extent_rec(level_node)]
	return extents


func _get_node_extent_rec(n: Node) -> Rect2:
	if _is_node_skipped(n):
		return ZERO_RECT
	
	var extent := _get_node_extent(n)
	
	for c in n.get_children():
		var child_extent := _get_node_extent_rec(c)
		if child_extent.size == Vector2.ZERO:
			continue
		if extent.size == Vector2.ZERO:
			extent = child_extent
		else:
			extent = extent.merge(child_extent)

	return extent


func _get_node_extent(n: Node) -> Rect2:
	if n is Control:
		return _get_node_extent_control(n)
	if n is Polygon2D:
		return _get_node_extent_polygon2d(n)
	if n is Sprite2D:
		return _get_node_extent_sprite(n)
	if n is TileMap:
		return _get_node_extent_tile_map(n)
	if n is TileMapLayer:
		return _get_node_extent_tile_map_layer(n)
	if n is MultiMeshInstance2D:
		return _get_node_extent_multimeshinstance2d(n)

	return ZERO_RECT


func _is_canvas_item_visible(c:CanvasItem) -> bool:
	return c.visible and c.modulate.a > .1 and c.self_modulate.a > .1


func _get_node_extent_control(c: Control) -> Rect2:
	if !_is_canvas_item_visible(c): return ZERO_RECT
	if c is ReferenceRect and c.editor_only:
		return ZERO_RECT
	return Rect2(c.global_position, c.size)


func _get_node_extent_polygon2d(p: Polygon2D) -> Rect2:
	if !_is_canvas_item_visible(p): return ZERO_RECT
	var min_v := Vector2.INF
	var max_v := Vector2.INF
	
	for i in p.polygon:
		var pt: Vector2 = i
		pt = p.to_global(pt)
		if min_v == Vector2.INF:
			min_v = pt
		else:
			if min_v.x > pt.x:
				min_v.x = pt.x
			if min_v.y > pt.y:
				min_v.y = pt.y
		if max_v == Vector2.INF:
			max_v = pt
		else:
			if max_v.x < pt.x:
				max_v.x = pt.x
			if max_v.y < pt.y:
				max_v.y = pt.y
	
	return Rect2(min_v, max_v - min_v)


func _get_node_extent_sprite(s: Sprite2D) -> Rect2:
	if !_is_canvas_item_visible(s): return ZERO_RECT
	if !s.texture: return ZERO_RECT
	var texture_size := s.texture.get_size() * s.scale
	var r := Rect2(s.global_position, texture_size)
	if s.centered:
		r.position -= .5 * texture_size
	return r


func _get_node_extent_tile_map(t: TileMap) -> Rect2:
	if !_is_canvas_item_visible(t): return ZERO_RECT
	if !t.tile_set: return ZERO_RECT
	var r := t.get_used_rect()
	var tile_size := t.tile_set.tile_size
	return Rect2(t.to_global(r.position * tile_size), r.size * tile_size)


func _get_node_extent_tile_map_layer(t:TileMapLayer) -> Rect2:
	if !_is_canvas_item_visible(t): return ZERO_RECT
	if !t.tile_set: return ZERO_RECT
	var r := t.get_used_rect()
	var tile_size := t.tile_set.tile_size
	return Rect2(t.to_global(r.position * tile_size), r.size * tile_size)


func _get_node_extent_multimeshinstance2d(m: MultiMeshInstance2D) -> Rect2:
	if !_is_canvas_item_visible(m): return ZERO_RECT
	var mm := m.multimesh
	var aabb := mm.get_aabb()
	
	var pos := Vector2(aabb.position.x, aabb.position.y)
	pos = m.to_global(pos)
	var size := Vector2(aabb.size.x, aabb.size.y)

	return Rect2(pos, size)
