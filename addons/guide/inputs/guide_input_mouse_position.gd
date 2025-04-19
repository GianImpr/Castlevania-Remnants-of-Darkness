@tool
class_name GUIDEInputMousePosition
extends GUIDEInput


func _begin_usage() -> void :
	_update_mouse_position()


func _input(event:InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
		
	_update_mouse_position()


func _update_mouse_position():
	var position:Vector2 = Engine.get_main_loop().root.get_mouse_position()

	_value.x = position.x
	_value.y = position.y
		
		
func is_same_as(other:GUIDEInput):
	return other is GUIDEInputMousePosition


func _to_string():
	return "(GUIDEInputMousePosition)"


func _editor_name() -> String:
	return "Mouse Position"

	
func _editor_description() -> String:
	return "Position of the mouse in the main viewport."


func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_2D
