@tool
class_name GUIDEInputTouchAxis2D
extends GUIDEInputTouchAxisBase

func _apply_value(value:Vector2):
	_value = Vector3(value.x, value.y, 0)
		
func is_same_as(other:GUIDEInput):
	return other is GUIDEInputTouchAxis2D and \
		other.finger_count == finger_count and \
		other.finger_index == finger_index


func _to_string():
	return "(GUIDEInputTouchAxis2D finger_count=" + str(finger_count) + \
		" finger_index=" + str(finger_index) +")"


func _editor_name() -> String:
	return "Touch Axis2D"

	
func _editor_description() -> String:
	return "2D relative movement of a touching finger."

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_2D
