## Limits inputs to positive or negative values.
@tool
class_name GUIDEModifierPositiveNegative
extends GUIDEModifier

enum LimitRange {
	POSITIVE = 1,
	NEGATIVE = 2
}

## The range of numbers to which the input should be limited
@export var range:LimitRange = LimitRange.POSITIVE

## Whether the X axis should be affected.
@export var x:bool = true:
	set(value):
		if x == value:
			return
		x = value
		emit_changed()
		
## Whether the Y axis should be affected.
@export var y:bool = true:
	set(value):
		if y == value:
			return
		y = value
		emit_changed()

## Whether the Z axis should be affected.
@export var z:bool = true:
	set(value):
		if z == value:
			return
		z = value
		emit_changed()

		

func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	if not input.is_finite():
		return Vector3.INF
		
	match range:
		LimitRange.POSITIVE:
			return Vector3(
				max(0, input.x) if x else input.x, \
				max(0, input.y) if y else input.y, \
				max(0, input.z) if z else input.z  \
			)
		LimitRange.NEGATIVE:
			return Vector3(
				min(0, input.x) if x else input.x, \
				min(0, input.y) if y else input.y, \
				min(0, input.z) if z else input.z  \
			)
	# should never happen
	return input

func _editor_name() -> String:
	return "Positive/Negative"	


func _editor_description() -> String:
	return "Clamps the input to positive or negative values."
