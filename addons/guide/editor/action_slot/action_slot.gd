@tool
extends LineEdit

signal action_changed()

var index:int

var action:GUIDEAction:
	set(value):
		if is_instance_valid(action):
			action.changed.disconnect(_refresh)
		
		action = value
	
		if is_instance_valid(action):
			action.changed.connect(_refresh)
	
		# action_changed can only be emitted by 
		# dragging an action into this, not when setting
		# the property
		_refresh()

		
func _refresh():
	if not is_instance_valid(action):
		text = "<none>"
		tooltip_text = ""
	else:
		text = action._editor_name()	
		tooltip_text = action.resource_path

func _can_drop_data(at_position, data) -> bool:
	if not data is Dictionary:
		return false
		
	if data.has("files"):
		for file in data["files"]:
			if ResourceLoader.load(file) is GUIDEAction:
				return true
		
	return false	
	
	
func _drop_data(at_position, data) -> void:
	
	for file in data["files"]:
		var item = ResourceLoader.load(file) 
		if item is GUIDEAction:
			action = item
			action_changed.emit()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_instance_valid(action):
				EditorInterface.edit_resource(action)

