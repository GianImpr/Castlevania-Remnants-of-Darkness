@tool
class_name GUIDEInputMouseButton
extends GUIDEInput


@export var button:MouseButton = MOUSE_BUTTON_LEFT:
	set(value):
		if value == button:
			return
		button = value
		emit_changed()		
	

func _needs_reset():
	# mouse wheel up and down can potentially send multiple inputs within a single frame
	# so we need to smooth this out a bit.
	return button == MOUSE_BUTTON_WHEEL_UP or button == MOUSE_BUTTON_WHEEL_DOWN

var _reset_to:Vector3
var _was_pressed_this_frame:bool 

func _reset() -> void:
	_was_pressed_this_frame = false
	_value = _reset_to

	
func _input(event:InputEvent):
	if not event is InputEventMouseButton:
		return
	
	if event.button_index != button:
		return
	
	
	if _needs_reset():
		# we always reset to the last event we received in a frame
		# so after the frame is over we're still in sync.
		_reset_to.x =  1.0 if event.pressed else 0.0
		
		if event.pressed:
			_was_pressed_this_frame = true
		
		if not event.pressed and _was_pressed_this_frame:
			# keep pressed state for this frame
			return
		
	_value.x = 1.0 if event.pressed else 0.0

func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputMouseButton and other.button == button


func _to_string():
	return "(GUIDEInputMouseButton: button=" + str(button) + ")"


func _editor_name() -> String:
	return "Mouse Button"
	
func _editor_description() -> String:
	return "A press of a mouse button. The mouse wheel is also a button."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.BOOL
