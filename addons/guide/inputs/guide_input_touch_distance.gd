## Input representing the distance changes between two fingers. 
@tool
class_name GUIDEInputTouchDistance
extends GUIDEInput

const GUIDETouchState = preload("guide_touch_state.gd")

var _initial_distance:float = INF

# We use the reset call to calculate the distance for this frame
# so it can serve as reference for the next frame
func _needs_reset() -> bool:
	return true

func _reset():
	var distance = _calculate_distance()
	# update initial distance when input is actuated or stops being actuated
	if is_finite(_initial_distance) != is_finite(distance):
		_initial_distance = distance
		

func _input(event:InputEvent) -> void:
	if not GUIDETouchState.process_input_event(event):
		# not touch-related
		return
		
	var distance := _calculate_distance()
	# if either current distance or initial distance is not set,
	# we are zero
	if not is_finite(distance) or not is_finite(_initial_distance):
		_value = Vector3.ZERO
		return
		
	# we assume that _initial_distance is never 0 because
	# you cannot have two fingers physically at the same place
	# on a touch screen
	_value = Vector3(distance / _initial_distance, 0, 0)
		
	
func _calculate_distance() -> float:
	var pos1:Vector2 = GUIDETouchState.get_finger_position(0, 2)
	# if we have no position for first finger, we can immediately abort
	if not pos1.is_finite():
		return INF
		
	var pos2:Vector2 = GUIDETouchState.get_finger_position(1, 2)
	# if there is no second finger, we can abort as well
	if not pos2.is_finite():
		return INF
		
	# calculate distance for the fingers
	return pos1.distance_to(pos2)
	
 		
func is_same_as(other:GUIDEInput):
	return other is GUIDEInputTouchDistance


func _to_string():
	return "(GUIDEInputTouchDistance)"


func _editor_name() -> String:
	return "Touch Distance"

	
func _editor_description() -> String:
	return "Distance of two touching fingers."


func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_1D
