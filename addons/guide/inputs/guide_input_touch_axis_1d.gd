@tool
class_name GUIDEInputTouchAxis1D
extends GUIDEInputTouchAxisBase

enum GUIDEInputTouchAxis {
	X,
	Y
}

@export var axis:GUIDEInputTouchAxis:
	set(value):
		if value == axis:
			return
		axis = value
		emit_changed()		
		
func is_same_as(other:GUIDEInput):
	return other is GUIDEInputTouchAxis1D and \
		other.finger_count == finger_count and \
		other.finger_index == finger_index and \
		other.axis == axis

func _apply_value(value:Vector2):
	match axis:
		GUIDEInputTouchAxis.X:
			_value = Vector3(value.x, 0, 0)
		GUIDEInputTouchAxis.Y:
			_value = Vector3(value.y, 0, 0)

func _to_string():
	return "(GUIDEInputTouchAxis1D finger_count=" + str(finger_count) + \
		" finger_index=" + str(finger_index) +" axis=" + ("X" if axis == GUIDEInputTouchAxis.X else "Y") + ")"


func _editor_name() -> String:
	return "Touch Axis1D"

	
func _editor_description() -> String:
	return "Relative movement of a touching finger on a single axis."


func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_1D
