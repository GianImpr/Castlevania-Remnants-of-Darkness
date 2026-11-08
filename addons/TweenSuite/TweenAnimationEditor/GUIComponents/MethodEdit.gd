@tool
extends "./BasePicker.gd"

func pick() -> void:
	EditorInterface.popup_method_selector(object_edit.object, on_picked, value)
