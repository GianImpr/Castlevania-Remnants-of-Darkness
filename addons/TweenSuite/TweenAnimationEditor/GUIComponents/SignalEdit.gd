@tool
extends "./BasePicker.gd"

@onready var signal_dialog: ConfirmationDialog = %SignalDialog
@onready var signal_list: Tree = %SignalList

func pick() -> void:
	var use_monospace_font: bool = EditorInterface.get_editor_settings().get_setting("interface/theme/use_monospace_font_for_editor_symbols")
	var monospace_font := get_theme_font(&"source", &"EditorFonts")
	
	signal_list.clear()
	signal_list.create_item()
	
	var object: Object = object_edit.object
	
	var object_script: Script = object.get_script()
	if object_script:
		var script_signals := object_script.get_script_signal_list()
		if not script_signals.is_empty():
			var script_item := signal_list.create_item()
			script_item.set_text(0, "Script")
			script_item.set_icon(0, EditorInterface.get_editor_theme().get_icon(&"Script", &"EditorIcons"))
			script_item.set_selectable(0, false)
			
			for signal_data in script_signals:
				var signal_item := script_item.create_child()
				signal_item.set_text(0, signal_data["name"])
				
				if use_monospace_font:
					signal_item.set_custom_font(0, monospace_font)
	
	var object_class: StringName = object.get_class()
	while not object_class.is_empty():
		var class_signals := ClassDB.class_get_signal_list(object_class, true)
		if not class_signals.is_empty():
			var class_item := signal_list.create_item()
			class_item.set_text(0, object_class)
			class_item.set_icon(0, EditorInterface.get_editor_theme().get_icon(object_class, &"EditorIcons"))
			class_item.set_selectable(0, false)
			
			for signal_data in class_signals:
				var signal_item := class_item.create_child()
				signal_item.set_text(0, signal_data["name"])
				
				if use_monospace_font:
					signal_item.set_custom_font(0, monospace_font)
		
		object_class = ClassDB.get_parent_class(object_class)
	
	signal_dialog.get_ok_button().disabled = true
	signal_dialog.popup_centered_clamped(Vector2(300, 600) * get_theme_default_base_scale())

func _signal_selected() -> void:
	signal_dialog.hide()
	on_picked(signal_list.get_selected().get_text(0))

func _on_signal_list_item_selected() -> void:
	signal_dialog.get_ok_button().disabled = signal_list.get_selected() == null
