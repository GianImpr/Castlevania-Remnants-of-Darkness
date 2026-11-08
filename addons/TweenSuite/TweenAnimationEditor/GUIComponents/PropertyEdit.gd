@tool
extends "./BasePicker.gd"

func pick() -> void:
	EditorInterface.popup_property_selector(object_edit.object, on_picked, [], value)
