@tool
extends RefCounted

# Editor Settings > Plugins > GDScript Templates

const FileUtils = preload("res://addons/gdscript-templates/scripts/file_utils.gd")

const PREFIX = "plugins/gdscript_templates/"
const USE_DEFAULT_TEMPLATES = PREFIX + "use_default_templates"
const SHOW_IN_CODE_COMPLETION = PREFIX + "show_in_code_completion"
const SHORTCUT_SHOW = PREFIX + "show_templates_shortcut"
const SHORTCUT_EXPAND = PREFIX + "expand_template_shortcut"

# 1.0 settings file
const LEGACY_SETTINGS_PATH = "user://code_templates_settings.json"

# used during 1.1 development
const OLD_PREFIX = "text_editor/gdscript_templates/"
const OLD_SHORTCUTS = ["gdscript_templates/show_templates", "gdscript_templates/expand_template"]
# the template browser is sized to the script editor and the preview now
const REMOVED_SETTINGS = [PREFIX + "popup_size", OLD_PREFIX + "popup_size"]

static func register() -> void:
	var settings = EditorInterface.get_editor_settings()

	for name in [USE_DEFAULT_TEMPLATES]:
		var old_name = name.replace(PREFIX, OLD_PREFIX)
		if settings.has_setting(old_name):
			if not settings.has_setting(name):
				settings.set_setting(name, settings.get_setting(old_name))
			settings.erase(old_name)
	for name in REMOVED_SETTINGS:
		if settings.has_setting(name):
			settings.erase(name)
	if settings.has_method("remove_shortcut"):
		for path in OLD_SHORTCUTS:
			settings.remove_shortcut(path)

	# first run - take the value from 1.0
	if not settings.has_setting(USE_DEFAULT_TEMPLATES):
		var legacy = FileUtils.load_json_file(LEGACY_SETTINGS_PATH)
		settings.set_setting(USE_DEFAULT_TEMPLATES, legacy.get("use_default_templates", true))

	_add_setting(settings, USE_DEFAULT_TEMPLATES, true, TYPE_BOOL)
	_add_setting(settings, SHOW_IN_CODE_COMPLETION, true, TYPE_BOOL)

	# separate default instance - the inspector edits the shortcut in place
	if not settings.has_setting(SHORTCUT_SHOW):
		settings.set_setting(SHORTCUT_SHOW, _create_shortcut(KEY_SPACE))
	_add_setting(settings, SHORTCUT_SHOW, _create_shortcut(KEY_SPACE), TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE, "Shortcut")
	if not settings.has_setting(SHORTCUT_EXPAND):
		settings.set_setting(SHORTCUT_EXPAND, _create_shortcut(KEY_E))
	_add_setting(settings, SHORTCUT_EXPAND, _create_shortcut(KEY_E), TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE, "Shortcut")

static func _add_setting(settings: EditorSettings, name: String, default_value, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = "") -> void:
	if not settings.has_setting(name):
		settings.set_setting(name, default_value)
	settings.set_initial_value(name, default_value, false)
	settings.add_property_info({"name": name, "type": type, "hint": hint, "hint_string": hint_string})

static func _create_shortcut(keycode: Key) -> Shortcut:
	var event = InputEventKey.new()
	event.keycode = keycode
	event.ctrl_pressed = true

	var shortcut = Shortcut.new()
	shortcut.events = [event]
	return shortcut

static func matches_shortcut(path: String, event: InputEvent) -> bool:
	var shortcut = EditorInterface.get_editor_settings().get_setting(path)
	return shortcut is Shortcut and shortcut.matches_event(event)

static func create_gdscript_highlighter() -> SyntaxHighlighter:
	if ClassDB.class_exists("GDScriptSyntaxHighlighter"):
		return ClassDB.instantiate("GDScriptSyntaxHighlighter")
	return null

static func use_default_templates() -> bool:
	return EditorInterface.get_editor_settings().get_setting(USE_DEFAULT_TEMPLATES)

static func show_in_code_completion() -> bool:
	return EditorInterface.get_editor_settings().get_setting(SHOW_IN_CODE_COMPLETION)
