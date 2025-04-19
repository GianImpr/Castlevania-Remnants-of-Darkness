@tool
## A trigger that activates when the input is tapped and released before the time threshold is reached.
class_name GUIDETriggerTap
extends GUIDETrigger

## The time threshold for the tap to be considered a tap.
@export var tap_threshold: float = 0.2

var _accumulated_time: float = 0


func _update_state(input: Vector3, delta: float, value_type:GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	if _is_actuated(input, value_type):
		# if the input was actuated before, and the tap threshold has been exceeded, the trigger is locked down
		# until the input is released and we can exit out early
		if _is_actuated(_last_value, value_type) and _accumulated_time > tap_threshold:
			return GUIDETriggerState.NONE

		# accumulate time
		_accumulated_time += delta

		if _accumulated_time < tap_threshold:
			return GUIDETriggerState.ONGOING
		else:
			# we have exceeded the tap threshold, so the tap is not triggered.
			return GUIDETriggerState.NONE

	else: # not actuated right now
		# if the input was actuated before...
		if _is_actuated(_last_value, value_type):
			# ... and the accumulated time is less than the threshold, then the tap is triggered.
			if _accumulated_time < tap_threshold:
				_accumulated_time = 0
				return GUIDETriggerState.TRIGGERED

			# Otherwise, the tap is not triggered, but we reset the accumulated time
			# so the trigger is now again ready to be triggered.
			_accumulated_time = 0
			
 		# in either case, the trigger is not triggered.
		return GUIDETriggerState.NONE

func _editor_name() -> String:
	return "Tap"


func _editor_description() -> String:
	return "Fires when the input is actuated and released within the given timeframe."
