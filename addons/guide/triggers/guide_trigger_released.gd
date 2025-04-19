@tool
## A trigger that activates when the input is released down. Will only emit a
## trigger event once.
class_name GUIDETriggerReleased
extends GUIDETrigger


func _update_state(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	if not _is_actuated(input, value_type):
		if _is_actuated(_last_value, value_type):
			return GUIDETriggerState.TRIGGERED
		
	return GUIDETriggerState.NONE


func _editor_name() -> String:
	return "Released"


func _editor_description() -> String:
	return "Fires once, when the input goes from actuated to not actuated. The opposite of the Pressed trigger."
