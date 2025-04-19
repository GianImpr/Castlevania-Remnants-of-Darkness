## Stateful modifier which provides a virtual "mouse" cursor driven by input. The modifier
## returns the current cursor position in pixels releative to the origin of the currently
## active window. 
@tool
class_name GUIDEModifierVirtualCursor
extends GUIDEModifier

enum ScreenScale {
	## Input is not scaled with input screen size. This means that the cursor will
	## visually move slower on higher resolutions.
	NONE = 0,
	## Input is scaled with the longer axis of the screen size (e.g. width in
	## landscape mode, height in portrait mode). The cursor will move with
	## the same visual speed on all resolutions.
	LONGER_AXIS = 1,
	## Input is scaled with the shorter axis of the screen size (e.g. height in
	## landscape mode, width in portrait mode). The cursor will move with the 
	## same visual speed on all resolutions.
	SHORTER_AXIS = 2
}

## The initial position of the virtual cursor (given in screen relative coordinates)
@export var initial_position:Vector2 = Vector2(0.5, 0.5):
	set(value):
		initial_position = value.clamp(Vector2.ZERO, Vector2.ONE)

## The cursor movement speed in pixels.
@export var speed:Vector3 = Vector3.ONE

## Screen scaling to be applied to the cursor movement. This controls
## whether the cursor movement speed is resolution dependent or not.
## If set to anything but [code]None[/code] then the input value will
## be multiplied with the window width/height depending on the setting.
@export var screen_scale:ScreenScale = ScreenScale.LONGER_AXIS

## The scale by which the input should be scaled.
## @deprecated: use [member speed] instead. 
var scale:Vector3:
	get: return speed
	set(value): speed = value

## If true, the cursor movement speed is in pixels per second, otherwise it is in pixels
## per frame.
@export var apply_delta_time:bool = true


## Cursor offset in pixels.
var _offset:Vector3 = Vector3.ZERO

## Returns the scaled screen size. This takes Godot's scaling factor for windows into account.
func _get_scaled_screen_size():
	# Get window size, including scaling factor
	var window = Engine.get_main_loop().get_root()
	return window.get_screen_transform().affine_inverse() * Vector2(window.size)

func _begin_usage():
	var window_size = _get_scaled_screen_size()
	_offset = Vector3(window_size.x * initial_position.x, window_size.y * initial_position.y, 0)


func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	if not input.is_finite():
		# input is invalid, so just return current cursor position
		return _offset
		
	var window_size = _get_scaled_screen_size() 
	input *= speed
		
	if apply_delta_time:
		input *= delta

	var screen_scale_factor:float = 1.0
	match screen_scale:
		ScreenScale.LONGER_AXIS:
			screen_scale_factor = max(window_size.x, window_size.y)
		ScreenScale.SHORTER_AXIS:
			screen_scale_factor = min(window_size.x, window_size.y)	
		
	input *= screen_scale_factor
		
	# apply input and clamp to window size	
	_offset = (_offset + input).clamp(Vector3.ZERO, Vector3(window_size.x, window_size.y, 0))
	
	return _offset

func _editor_name() -> String:
	return "Virtual Cursor"


func _editor_description() -> String:
	return "Stateful modifier which provides a virtual \"mouse\" cursor driven by input. The modifier\n" + \
			"returns the current cursor position in pixels releative to the origin of the currently \n" + \
			"active window."


# support for legacy properties
func _get_property_list():
	return [
		{
			"name": "scale",
			"type": TYPE_VECTOR3,
			"usage": PROPERTY_USAGE_NO_EDITOR
		}
	]
	
