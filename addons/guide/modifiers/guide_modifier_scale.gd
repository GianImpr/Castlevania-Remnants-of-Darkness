@tool
## Scales the input by the given value and optionally, delta time.
class_name GUIDEModifierScale
extends GUIDEModifier

## The scale by which the input should be scaled.
@export var scale:Vector3 = Vector3.ONE:
	set(value):
		scale = value
		emit_changed()
		
		
## If true, delta time will be multiplied in addition to the scale.
@export var apply_delta_time:bool = false:
	set(value):
		apply_delta_time = value
		emit_changed()


func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	if not input.is_finite():
		return Vector3.INF
		
	if apply_delta_time:
		return input * scale * delta
	else:
		return input * scale


func _editor_name() -> String:
	return "Scale"


func _editor_description() -> String:
	return "Scales the input by the given value and optionally, delta time."
