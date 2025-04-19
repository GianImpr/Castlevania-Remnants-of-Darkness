@tool
class_name GUIDEInputKey
extends GUIDEInput

## The physical keycode of the key.
@export var key:Key:
	set(value):
		if value == key:
			return
		key = value
		emit_changed()	
		

@export_group("Modifiers")
## Whether shift must be pressed.
@export var shift:bool = false:
	set(value):
		if value == shift:
			return
		shift = value
		emit_changed()	

## Whether control must be pressed.
@export var control:bool = false:
	set(value):
		if value == control:
			return
		control = value
		emit_changed()	
		
## Whether alt must be pressed.
@export var alt:bool = false:
	set(value):
		if value == alt:
			return
		alt = value
		emit_changed()		
	
		
## Whether meta/win/cmd must be pressed.
@export var meta:bool = false:
	set(value):
		if value == meta:
			return
		meta = value
		emit_changed()	

## Whether this input should fire if additional
## modifier keys are currently pressed.		
@export var allow_additional_modifiers:bool = true:
	set(value):
		if value == allow_additional_modifiers:
			return
		allow_additional_modifiers = value
		emit_changed()
					


func _input(event:InputEvent):
	if not event is InputEventKey:
		return
	
	# we start assuming the key is not pressed right now	
	_value.x = 0.0
	
	# the key itself must be pressed
	if not Input.is_physical_key_pressed(key):
		return
		
	# every required modifier must be pressed
	if shift and not Input.is_physical_key_pressed(KEY_SHIFT):
		return
		
	if control and not Input.is_physical_key_pressed(KEY_CTRL):
		return
		
	if alt and not Input.is_physical_key_pressed(KEY_ALT):
		return
		
	if meta and not Input.is_physical_key_pressed(KEY_META):
		return
		
	# unless additional modifiers are allowed, every
	# unselected modifier must not be pressed (except if the 
	# bound key is actually the modifier itself)
	
	if not allow_additional_modifiers:
		if not shift and key != KEY_SHIFT and Input.is_physical_key_pressed(KEY_SHIFT):
			return
		
		if not control and key != KEY_CTRL and Input.is_physical_key_pressed(KEY_CTRL):
			return
		
		if not alt and key != KEY_ALT and Input.is_physical_key_pressed(KEY_ALT):
			return
		
		if not meta and key != KEY_META and Input.is_physical_key_pressed(KEY_META):
			return
		
	# we're still here, so all required keys are pressed and 
	# no extra keys are pressed
	
	_value.x = 1.0	
	

func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputKey \
			and other.key == key \
			and other.shift == shift \
			and other.control == control \
			and other.alt == alt \
			and other.meta == meta \
			and other.allow_additional_modifiers == allow_additional_modifiers

func _to_string():
	return "(GUIDEInputKey: key=" + str(key) + ", shift="  + str(shift) + ", alt=" + str(alt) + ", control=" + str(control) + ", meta="+ str(meta) + ")"


func _editor_name() -> String:
	return "Key"
	
func _editor_description() -> String:
	return "A button press on the keyboard."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.BOOL
