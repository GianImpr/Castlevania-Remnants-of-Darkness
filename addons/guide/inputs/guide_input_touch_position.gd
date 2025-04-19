@tool
class_name GUIDEInputTouchPosition
extends GUIDEInputTouchBase

const GUIDETouchState = preload("guide_touch_state.gd")


func _begin_usage():
	_value = Vector3.INF
	

func _input(event:InputEvent) -> void:
	# update touch state
	if not GUIDETouchState.process_input_event(event):
	 	# not touch-related
		return
		
	# update finger position
	var position := GUIDETouchState.get_finger_position(finger_index, finger_count)
	if not position.is_finite():
		_value = Vector3.INF
		return
		
	_value = Vector3(position.x, position.y, 0) 

		
func is_same_as(other:GUIDEInput):
	return other is GUIDEInputTouchPosition and \
		other.finger_count == finger_count and \
		other.finger_index == finger_index


func _to_string():
	return "(GUIDEInputTouchPosition finger_count=" + str(finger_count) + \
		" finger_index=" + str(finger_index) +")"


func _editor_name() -> String:
	return "Touch Position"

	
func _editor_description() -> String:
	return "Position of a touching finger."


func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_2D
