@tool
extends Button

@export var icon_name: StringName:
	set(iconame):
		if iconame == icon_name:
			return
		
		icon_name = iconame
		if not Engine.is_editor_hint():
			return
		
		if EditorInterface.get_editor_theme().has_icon(icon_name, &"EditorIcons"):
			icon = EditorInterface.get_editor_theme().get_icon(icon_name, &"EditorIcons")

func _validate_property(property: Dictionary) -> void:
	if property.name == "icon":
		property.usage = PROPERTY_USAGE_NONE
