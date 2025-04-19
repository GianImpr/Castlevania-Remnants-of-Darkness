@tool
class_name GUIDEInputJoyButton
extends GUIDEInputJoyBase

@export var button:JoyButton = JOY_BUTTON_A:
	set(value):
		if value == button:
			return
		button = value
		emit_changed()		

func _input(event:InputEvent):
	if not event is InputEventJoypadButton:
		return
	
	if event.button_index != button:
		return
	
	
	if joy_index > -1 and event.device != _joy_id:
		return
		
	_value.x = 1.0 if event.pressed else 0.0


func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputJoyButton and \
		 other.button == button and \
		 other.joy_index == joy_index


func _to_string():
	return "(GUIDEInputJoyButton: button=" + str(button) + ", joy_index="  + str(joy_index) + ")"


func _editor_name() -> String:
	return "Joy Button"
	
func _editor_description() -> String:
	return "A button press from a joy button."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.BOOL
