## Input from two joy axes.
class_name GUIDEInputJoyAxis2D
extends GUIDEInputJoyBase

## The joy axis to sample for x input.
@export var x:JoyAxis = JOY_AXIS_LEFT_X:
	set(value):
		if value == x:
			return
		x = value
		emit_changed()
		
		
## The joy axis to sample for y input.
@export var y:JoyAxis = JOY_AXIS_LEFT_Y:
	set(value):
		if value == y:
			return
		y = value
		emit_changed()


func _input(event:InputEvent):
	if not event is InputEventJoypadMotion:
		return
		
	if event.axis != x and event.axis != y:
		return
		
	if joy_index > -1 and event.device != _joy_id:
		return
		
	if event.axis == x:
		_value.x = event.axis_value
		return
		
	if event.axis == y:
		_value.y = event.axis_value

func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputJoyAxis2D and \
		other.x == x and \
		other.y == y and \
		other.joy_index == joy_index

func _to_string():
	return "(GUIDEInputJoyAxis2D: x=" + str(x) + ", y=" + str(y) + ", joy_index="  + str(joy_index) + ")"


func _editor_name() -> String:
	return "Joy Axis 2D"
	
func _editor_description() -> String:
	return "The input from two Joy axes. Usually from a stick."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_2D
