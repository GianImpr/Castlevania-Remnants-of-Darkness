## Normalizes the input vector.
@tool
class_name GUIDEModifierNormalize
extends GUIDEModifier

func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	if not input.is_finite():
		return Vector3.INF
		
	return input.normalized()

func _editor_name() -> String:
	return "Normalize"	


func _editor_description() -> String:
	return "Normalizes the input vector."
