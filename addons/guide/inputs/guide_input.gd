@tool
@icon("res://addons/guide/inputs/guide_input.svg")
## A class representing some actuated input.
class_name GUIDEInput
extends Resource

## The current valueo f this input. Depending on the input type only parts of the 
## returned vector may be relevant.
var _value:Vector3 = Vector3.ZERO

## Whether this input needs a reset per frame. _input is only called when
## there is input happening, but some GUIDE inputs may need to be reset
## in the absence of input.
func _needs_reset() -> bool:
	return false
	
## Resets the input value to the default value. Is called once per frame if
## _needs_reset returns true.
func _reset() -> void:
	_value = Vector3.ZERO

## Called when an input event happens. Should update the 
## the input value of this input.
func _input(event:InputEvent):
	pass
	
## Returns whether this input is the same input as the other input.
func is_same_as(other:GUIDEInput) -> bool:
	return false
	
## Called when the input is started to be used by GUIDE. Can be used to perform
## initializations.
func _begin_usage() -> void :
	pass
	
## Called, when the input is no longer used by GUIDE. Can be used to perform
## cleanup.
func _end_usage() -> void:
	pass
	
	
func _editor_name() -> String:
	return ""
	
func _editor_description() -> String:
	return ""
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return -1
