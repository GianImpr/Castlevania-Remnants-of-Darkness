## Inverts input per axis.
@tool
class_name GUIDEModifierNegate
extends GUIDEModifier

## Whether the X axis should be inverted.
@export var x:bool = true:
	set(value):
		if x == value:
			return
		x = value
		_update_caches()
		emit_changed()
		
## Whether the Y axis should be inverted.		
@export var y:bool = true:
	set(value):
		if y == value:
			return
		y = value
		_update_caches()
		emit_changed()

## Whether the Z axis should be inverted.
@export var z:bool = true:
	set(value):
		if z == value:
			return
		z = value
		_update_caches()
		emit_changed()

var _multiplier:Vector3 = Vector3.ONE * -1

func _update_caches():
	_multiplier.x = -1 if x else 1
	_multiplier.y = -1 if y else 1
	_multiplier.z = -1 if z else 1
		

func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	if not input.is_finite():
		return Vector3.INF
		
	return input * _multiplier

func _editor_name() -> String:
	return "Negate"	


func _editor_description() -> String:
	return "Inverts input per axis."
