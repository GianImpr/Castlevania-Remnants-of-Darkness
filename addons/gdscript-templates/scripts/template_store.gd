@tool
extends RefCounted

# Templates are merged from three files, later ones override earlier ones:
#   defaults  - shipped with the plugin
#   user      - editor config folder, shared by all projects
#   project   - res://.gdscript_templates.json, can be committed and shared with the team
# Entry: {body, description, category}. JSON value is a body string or {"body", "description", "category"}.

const FileUtils = preload("res://addons/gdscript-templates/scripts/file_utils.gd")
const Debug = preload("res://addons/gdscript-templates/scripts/debug_utils.gd")

const DEFAULTS_PATH = "res://addons/gdscript-templates/templates/templates.json"
const USER_FILE_NAME = "gdscript_templates.json"
const PROJECT_PATH = "res://.gdscript_templates.json"
# how many times each template was inserted, the browser lists the most used first
const USAGE_FILE_NAME = "gdscript_templates_usage.json"

# 1.0 user templates (per project)
const LEGACY_USER_PATH = "user://code_templates.json"

var defaults: Dictionary = {}
var user: Dictionary = {}
var project: Dictionary = {}
var usage: Dictionary = {}
var use_defaults: bool = true

# defaults merged with user and project templates
var templates: Dictionary = {}

# modified times of the files when they were loaded, to reload them after a change
var _loaded_times: Dictionary = {}

static func get_user_path() -> String:
	return EditorInterface.get_editor_paths().get_config_dir().path_join(USER_FILE_NAME)

static func get_project_path() -> String:
	return ProjectSettings.globalize_path(PROJECT_PATH)

static func _get_usage_path() -> String:
	return EditorInterface.get_editor_paths().get_config_dir().path_join(USAGE_FILE_NAME)

func load_templates() -> void:
	defaults = normalize(FileUtils.load_json_file(DEFAULTS_PATH))

	var user_path = get_user_path()
	if not FileAccess.file_exists(user_path) and FileAccess.file_exists(LEGACY_USER_PATH):
		var legacy = FileUtils.load_json_file(LEGACY_USER_PATH)
		if not legacy.is_empty() and FileUtils.save_json_file(legacy, user_path):
			Debug.info("✓ User templates migrated to %s" % user_path)

	user = _load(user_path)
	project = _load(get_project_path())
	usage = FileUtils.load_json_file(_get_usage_path())
	rebuild()

func _load(path: String) -> Dictionary:
	_loaded_times[path] = _modified_time(path)
	return normalize(FileUtils.load_json_file(path))

static func _modified_time(path: String) -> int:
	return FileAccess.get_modified_time(path) if FileAccess.file_exists(path) else 0

# picks up changes made to the files outside the plugin, returns true when something was reloaded
func reload_if_changed() -> bool:
	var changed = false
	for path in [get_user_path(), get_project_path()]:
		if _modified_time(path) != _loaded_times.get(path, 0):
			changed = true
	if changed:
		user = _load(get_user_path())
		project = _load(get_project_path())
		rebuild()
		Debug.info("✓ Templates reloaded")
	return changed

func rebuild() -> void:
	templates = defaults.duplicate(true) if use_defaults else {}
	templates.merge(user, true)
	templates.merge(project, true)
	# a changed default template without a category (made before 1.4) keeps the original one
	if not use_defaults:
		return
	for keyword in templates:
		var entry = templates[keyword]
		if entry.category.is_empty() and defaults.has(keyword):
			var with_category = entry.duplicate()
			with_category.category = defaults[keyword].category
			templates[keyword] = with_category

# categories in the order of the default templates, then the others alphabetically,
# "" (templates without a category) last
func get_categories() -> PackedStringArray:
	var categories = PackedStringArray()
	for keyword in defaults:
		if not categories.has(defaults[keyword].category):
			categories.append(defaults[keyword].category)
	var others = PackedStringArray()
	var uncategorized = false
	for keyword in templates:
		var category = templates[keyword].category
		if category.is_empty():
			uncategorized = true
		elif not categories.has(category) and not others.has(category):
			others.append(category)
	others.sort()
	categories.append_array(others)
	if uncategorized:
		categories.append("")
	return categories

func save_templates(new_user: Dictionary, new_project: Dictionary) -> bool:
	user = new_user.duplicate(true)
	project = new_project.duplicate(true)
	rebuild()

	var ok = _save(user, get_user_path())
	# no empty project file in projects without project templates
	if not project.is_empty() or FileAccess.file_exists(get_project_path()):
		ok = _save(project, get_project_path()) and ok
	return ok

func _save(entries: Dictionary, path: String) -> bool:
	var ok = FileUtils.save_json_file(serialize(entries), path)
	_loaded_times[path] = _modified_time(path)
	return ok

func record_use(keyword: String) -> void:
	usage[keyword] = int(usage.get(keyword, 0)) + 1
	FileUtils.save_json_file(usage, _get_usage_path())

# case insensitive unless case_sensitive, "" when not found
func find_keyword(word: String, case_sensitive: bool = false) -> String:
	if templates.has(word):
		return word
	if case_sensitive:
		return ""
	var word_lower = word.to_lower()
	for keyword in templates:
		if keyword.to_lower() == word_lower:
			return keyword
	return ""

static func normalize(raw: Dictionary) -> Dictionary:
	var result = {}
	for keyword in raw:
		var value = raw[keyword]
		if value is String:
			result[keyword] = {"body": value, "description": "", "category": ""}
		elif value is Dictionary and value.has("body"):
			result[keyword] = {
				"body": str(value.body),
				"description": str(value.get("description", "")),
				"category": str(value.get("category", "")),
			}
		else:
			push_warning("GDScript Templates: invalid template \"%s\" skipped" % keyword)
	return result

static func serialize(entries: Dictionary) -> Dictionary:
	var result = {}
	for keyword in entries:
		var entry = entries[keyword]
		if entry.description.is_empty() and entry.category.is_empty():
			result[keyword] = entry.body
		else:
			var value = {"body": entry.body}
			if not entry.description.is_empty():
				value.description = entry.description
			if not entry.category.is_empty():
				value.category = entry.category
			result[keyword] = value
	return result
