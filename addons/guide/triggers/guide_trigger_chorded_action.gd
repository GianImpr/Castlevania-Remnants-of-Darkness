## Fires, when the given action is currently triggering. This trigger is implicit,
## so it will prevent the action from triggering even if other triggers are successful.
@tool
class_name GUIDETriggerChordedAction
extends GUIDETrigger

@export var action:GUIDEAction


func _get_trigger_type() -> GUIDETriggerType: 
	return GUIDETriggerType.IMPLICIT

func _update_state(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	if action == null:
		push_warning("Chorded trigger without action will never trigger.")
		return GUIDETriggerState.NONE
	
	if action.is_triggered():
		return GUIDETriggerState.TRIGGERED
	return GUIDETriggerState.NONE


func _editor_name() -> String:
	return "Chorded Action"

func _editor_description() -> String:
	return "Fires, when the given action is currently triggering. This trigger is implicit,\n" + \
 				"so it will prevent the action from triggering even if other triggers are successful."
