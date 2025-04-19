## Base class for joystick inputs.
@tool
class_name GUIDEInputJoyBase
extends GUIDEInput

## The index of the connected joy pad to check. If -1 checks all joypads.
@export var joy_index:int = -1:
	set(value):
		if value == joy_index:
			return
		joy_index = value
		emit_changed()	

## Cached joystick ID if we use a joy index.
var _joy_id:int = -2

func _begin_usage():
	Input.joy_connection_changed.connect(_update_joy_id)
	_update_joy_id(null, null)
	
func _end_usage():
	Input.joy_connection_changed.disconnect(_update_joy_id)
	
func _update_joy_id(_ignore, _ignore2):
	if joy_index < 0:
		return 
		
	var joypads:Array[int] = Input.get_connected_joypads()
	if joy_index < joypads.size():
		_joy_id = joypads[joy_index]
	else:
		push_warning("Only ", joypads.size(), " joy pads/sticks connected. Cannot sample in put from index ", joy_index, ".")
		_joy_id = -2
	

