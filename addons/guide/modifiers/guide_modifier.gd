@tool
@icon("res://addons/guide/modifiers/guide_modifier.svg")
class_name GUIDEModifier
extends Resource

## Called when the modifier is started to be used by GUIDE. Can be used to perform
## initializations.
func _begin_usage() -> void :
	pass
	
## Called, when the modifier is no longer used by GUIDE. Can be used to perform
## cleanup.
func _end_usage() -> void:
	pass

func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	return input

func _editor_name() -> String:
	return ""

func _editor_description() -> String:
	return ""
