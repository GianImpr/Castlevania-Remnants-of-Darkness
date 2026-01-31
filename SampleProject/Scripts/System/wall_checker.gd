extends Node
class_name WallChecker
@onready var parent: RigidBody2D = get_parent()

func _ready() -> void:
	await get_tree().physics_frame
	
	if checkOverlap():
		parent.queue_free()
		return

## Checks if the node is overlapping detectable collisions.
func checkOverlap() -> bool:
	var space_state = parent.get_world_2d().direct_space_state
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = parent.collision.shape
	query.transform = parent.transform.scaled_local(Vector2(0.8,0.8))
	#query.transform.origin = Vector2(0,0)
	
	query.collision_mask = parent.collision_mask 
	
	var result = space_state.intersect_shape(query)
	
	return result.size() > 0
