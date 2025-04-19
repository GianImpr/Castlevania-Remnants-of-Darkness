## Input from a single joy axis.
@tool
class_name GUIDEInputJoyAxis1D
extends GUIDEInputJoyBase

## The joy axis to sample
@export var axis:JoyAxis = JOY_AXIS_LEFT_X:
	set(value):
		if value == axis:
			return
		axis = value
		emit_changed()	

func _input(event:InputEvent):
	if not event is InputEventJoypadMotion:
		return
		
	if event.axis != axis:
		return
		
	if joy_index > -1 and event.device != _joy_id:
		return
		
	_value.x = event.axis_value


func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputJoyAxis1D and \
		other.axis == axis and \
		other.joy_index == joy_index

func _to_string():
	return "(GUIDEInputJoyAxis1D: axis=" + str(axis) + ", joy_index="  + str(joy_index) + ")"

func _editor_name() -> String:
	return "Joy Axis 1D"
	
func _editor_description() -> String:
	return "The input from a single joy axis."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_1D
