## Swizzle the input vector components. Useful to map 1D input to 2D or vice versa.
@tool
class_name GUIDEModifierInputSwizzle
extends GUIDEModifier

enum GUIDEInputSwizzleOperation {
	## Swap X and Y axes.
	YXZ,
	## Swap X and Z axes.
	ZYX,
	## Swap Y and Z axes.
	XZY,
	## Y to X, Z to Y, X to Z.
	YZX,
	## Y to Z, Z to X, X to Y.
	ZXY
}

## The new order into which the input should be brought.
@export var order:GUIDEInputSwizzleOperation = GUIDEInputSwizzleOperation.YXZ


func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	match order:
		GUIDEInputSwizzleOperation.YXZ:
			return Vector3(input.y, input.x, input.z)
		GUIDEInputSwizzleOperation.ZYX:
			return Vector3(input.z, input.y, input.x)
		GUIDEInputSwizzleOperation.XZY:
			return Vector3(input.x, input.z, input.y)
		GUIDEInputSwizzleOperation.YZX:
			return Vector3(input.y, input.z, input.x)
		GUIDEInputSwizzleOperation.ZXY:
			return Vector3(input.z, input.x, input.y)
		_:
			push_error("Unknown order ", order , " this is most likely a bug, please report it.")
			return input
			
func _editor_name() -> String:
	return "Input Swizzle"				
			
func _editor_description() -> String:
	return "Swizzle the input vector components. Useful to map 1D input to 2D or vice versa."
