extends Node2D

@export var speed:float = 100

@export var left_action:GUIDEAction
@export var right_action:GUIDEAction
@export var up_action:GUIDEAction
@export var down_action:GUIDEAction

func _process(delta:float) -> void:
	# This is close to how input would be handled with Godot's built-in
	# input. GUIDE can actually combine the input into a 2D axis for you
	# (similar to Godot's Input.get_vector). Because this is
	# done in the mapping context, the script doesn't need to know about
	# it. Look at the 2d_axis_mapping example to see how to streamline
	# this code quite a bit.
	
	var offset:Vector2 = Vector2.ZERO
	
	if left_action.is_triggered():
		offset.x = -1
	
	if right_action.is_triggered():
		offset.x = 1
		
	if up_action.is_triggered():
		offset.y = -1
		
	if down_action.is_triggered():
		offset.y = 1
		
	position += offset * speed * delta
