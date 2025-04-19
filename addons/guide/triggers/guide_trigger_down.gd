## Fires, when the input exceeds the actuation threshold. This is
## the default trigger when no trigger is specified.
@tool
class_name GUIDETriggerDown
extends GUIDETrigger

func _update_state(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	# if the input is actuated, then the trigger is triggered.
	if _is_actuated(input, value_type):
		return GUIDETriggerState.TRIGGERED
	# otherwise, the trigger is not triggered.
	return GUIDETriggerState.NONE


func _editor_name() -> String:
	return "Down"

func _editor_description() -> String:
	return "Fires, when the input exceeds the actuation threshold. This is\n" +\
			"the default trigger when no trigger is specified."
