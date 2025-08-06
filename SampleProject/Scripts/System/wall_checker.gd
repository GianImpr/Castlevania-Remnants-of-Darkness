extends Node
class_name WallChecker
@onready var parent: RigidBody2D = get_parent()

var min_x: float
const MAX_VERTICES_POSSIBLE: int = 4
const SPAWN_DELAY: float = 0.05
var local_collision_pos: Array[Vector2] = [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]

func _ready() -> void:
	parent.visible = false
	get_tree().create_timer(SPAWN_DELAY).timeout.connect(freeIfInsideWall)

func freeIfInsideWall() -> void:
	if parent.animation.current_animation == "picked":
		return
		
	if isInsideWall():
		parent.queue_free()
	else:
		parent.visible = true

# Must be called inside _integrate_forces in the parent node
func checkAndSortVertices(state: PhysicsDirectBodyState2D) -> void:
	var vertices = state.get_contact_count()
	if vertices > MAX_VERTICES_POSSIBLE:
		parent.queue_free()
		return
		
	if vertices == MAX_VERTICES_POSSIBLE:
		for i in range(0, MAX_VERTICES_POSSIBLE):
			local_collision_pos[i] = state.get_contact_local_position(i)
		local_collision_pos.sort_custom(func sort_x(a, b): return a.x < b.x)
		min_x = local_collision_pos[0].x
		local_collision_pos.sort_custom(sort_y)
		pass

# Sorts the coordinates of the vertices
# First half ascending
# Second half descending
func sort_y(a: Vector2, b: Vector2) -> bool:
	if (a.x != b.x):
		return false
		
	if (a.x == min_x):
		return a.y < b.y
	else:
		return a.y > b.y

# The pickup is stuck inside a wall if, given 4 vertices, with p0 being the top left vertex
# and p3 the top right vertex:
# 1. x0 = x1
# 2. x2 = x3
# 3. x0 != x2 (and x1 != x3, but if 1 and 2 are true, then x0 != x2 = x1 != x3)
# 4. y0 = y3
# 5. y1 = y2
# 6. y0 != y1 (same reason as 3)
func isInsideWall() -> bool:
	var are_x0_x1_equal: bool = local_collision_pos[0].x == local_collision_pos[1].x
	var are_x2_x3_equal: bool = local_collision_pos[2].x == local_collision_pos[3].x
	var are_x0_x2_different: bool = local_collision_pos[0].x != local_collision_pos[2].x
	var are_y0_y3_equal: bool = local_collision_pos[0].y == local_collision_pos[3].y
	var are_y1_y2_equal: bool = local_collision_pos[1].y == local_collision_pos[2].y
	var are_y0_y1_different: bool = local_collision_pos[0].y != local_collision_pos[1].y
	
	return are_x0_x1_equal and are_x2_x3_equal and are_x0_x2_different and are_y0_y3_equal \
		   and are_y1_y2_equal and are_y0_y1_different
