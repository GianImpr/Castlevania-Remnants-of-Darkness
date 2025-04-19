@tool
extends GUIDEIconRenderer

@onready var _label:Label = %Label

func supports(input:GUIDEInput) -> bool:
	return input is GUIDEInputKey
	
func render(input:GUIDEInput) -> void:
	var key:Key = input.key
	var label_key:Key = DisplayServer.keyboard_get_label_from_physical(key)
	_label.text = OS.get_keycode_string(label_key).strip_edges()
	size = Vector2.ZERO
	call("queue_sort")
 
func cache_key(input:GUIDEInput) -> String:
	return "ed6923d5-4115-44bd-b35e-2c4102ffc83e" + input.to_string()
