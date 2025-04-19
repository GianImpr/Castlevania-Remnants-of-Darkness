@tool
## Triggers depending on whether the input changes while actuated. This trigger is
## is implicit, so it must succeed for all other triggers to succeed.
class_name GUIDETriggerStability
extends GUIDETrigger

enum TriggerWhen {
	## Input must be stable
	INPUT_IS_STABLE,
	## Input must change
	INPUT_CHANGES
}


## The maximum amount that the input can change after actuation before it is 
## considered "changed".
@export var max_deviation:float = 1

## When should the trigger trigger?
@export var trigger_when:TriggerWhen = TriggerWhen.INPUT_IS_STABLE


var _initial_value:Vector3
var _deviated:bool = false


func _get_trigger_type() -> GUIDETriggerType: 
	return GUIDETriggerType.IMPLICIT


func _update_state(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	if _is_actuated(input, value_type):
		if _deviated:
			if trigger_when == TriggerWhen.INPUT_IS_STABLE:
				return GUIDETriggerState.NONE
			return GUIDETriggerState.TRIGGERED
		
		
		if not _is_actuated(_last_value, value_type):
			# we went from "not actuated" to actuated, start
			_initial_value = input
			if trigger_when == TriggerWhen.INPUT_IS_STABLE:
				return GUIDETriggerState.TRIGGERED
			else:
				return GUIDETriggerState.ONGOING
				
		# calculate how far the input is from the initial value
		if _initial_value.distance_squared_to(input) > (max_deviation * max_deviation):
			_deviated = true
			if trigger_when == TriggerWhen.INPUT_IS_STABLE:
				return GUIDETriggerState.NONE
			return GUIDETriggerState.TRIGGERED
		
		if trigger_when == TriggerWhen.INPUT_IS_STABLE:
			return GUIDETriggerState.TRIGGERED

		return GUIDETriggerState.ONGOING	

	# if the input is not actuated
	_deviated = false		
	return GUIDETriggerState.NONE
		

		
		
func _editor_name() -> String:
	return "Stability"		


func _editor_description() -> String:
	return "Triggers depending on whether the input changes while actuated. This trigger\n" +\
		"is implicit, so it must succeed for all other triggers to succeed."
