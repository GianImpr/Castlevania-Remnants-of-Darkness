@tool
class_name GUIDEInputMouseAxis2D
extends GUIDEInput


# we don't get mouse updates when the mouse is not moving, so this needs to be 
# reset every frame
func _needs_reset() -> bool:
	return true

func _input(event:InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return

	_value.x = event.relative.x
	_value.y = event.relative.y
		
func is_same_as(other:GUIDEInput):
	return other is GUIDEInputMouseAxis2D


func _to_string():
	return "(GUIDEInputMouseAxis2D)"


func _editor_name() -> String:
	return "Mouse Axis 2D"

	
func _editor_description() -> String:
	return "Relative mouse movement on 2 axes."


func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_2D
