## Input that triggers if any input from the given device class
## is given. Only looks for button inputs, not axis inputs as axes
## have a tendency to accidentally trigger.
@tool
class_name GUIDEInputAny
extends GUIDEInput


## Should input from mouse buttons be considered? Deprecated, use
## mouse_buttons instead.
## @deprecated 
var mouse:bool:
	get: return mouse_buttons
	set(value): mouse_buttons = value

## Should input from joy buttons be considered. Deprecated, use
## joy_buttons instead.
## @deprecated
var joy:bool:
	get: return joy_buttons
	set(value): joy_buttons = value

## Should input from mouse buttons be considered?
@export var mouse_buttons:bool = false
		
## Should input from mouse movement be considered?
@export var mouse_movement:bool = false

## Should input from gamepad/joystick buttons be considered?
@export var joy_buttons:bool = false

## Should input from gamepad/joystick axes be considered?
@export var joy_axes:bool = false 

## Should input from the keyboard be considered?
@export var keyboard:bool = false

## Should input from touch be considered?
@export var touch:bool = false


func _needs_reset() -> bool:
	# Needs reset because we cannot detect the absence of input.
	return true

func _input(event:InputEvent):
	if mouse_buttons and event is InputEventMouseButton:
		_value = Vector3.RIGHT
		return
		
	if mouse_movement and event is InputEventMouseMotion:
		_value = Vector3.RIGHT
		return
			
	if joy_buttons and event is InputEventJoypadButton:
		_value = Vector3.RIGHT
		return 
		
	if joy_axes and event is InputEventJoypadMotion:
		_value = Vector3.RIGHT
		return
			
	if keyboard and event is InputEventKey:
		_value = Vector3.RIGHT
		return
		
	if touch and (event is InputEventScreenTouch or event is InputEventScreenDrag):
		_value = Vector3.RIGHT
		return
		
	_value = Vector3.ZERO		


func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputAny and \
		other.mouse == mouse and \
		other.joy == joy and \
		other.keyboard == keyboard 

func _editor_name() -> String:
	return "Any Input"
	
	
func _editor_description() -> String:
	return "Input that triggers if any input from the given device class is given."
	
	
func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.BOOL

# support for legacy properties
func _get_property_list():
	return [
		{
			"name": "mouse",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_NO_EDITOR
		},
		{
			"name": "joy",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_NO_EDITOR
		}
	]
	
