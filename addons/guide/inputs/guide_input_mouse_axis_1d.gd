@tool
class_name GUIDEInputMouseAxis1D
extends GUIDEInput

enum GUIDEInputMouseAxis {
	X,
	Y
}

@export var axis:GUIDEInputMouseAxis:
	set(value):
		if value == axis:
			return
		axis = value
		emit_changed()		

# we don't get mouse updates when the mouse is not moving, so this needs to be 
# reset every frame
func _needs_reset() -> bool:
	return true

func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		match axis:
			GUIDEInputMouseAxis.X:
				_value.x = event.relative.x
			GUIDEInputMouseAxis.Y:
				_value.x = event.relative.y

		
func is_same_as(other:GUIDEInput):
	return other is GUIDEInputMouseAxis1D and other.axis == axis

func _to_string():
	return "(GUIDEInputMouseAxis1D: axis=" + str(axis) + ")"


func _editor_name() -> String:
	return "Mouse Axis 1D"
	
	
func _editor_description() -> String:
	return "Relative mouse movement on a single axis."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_1D
