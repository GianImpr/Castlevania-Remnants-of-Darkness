@tool
extends RefCounted

# Template syntax:
#   {name}          parameter
#   {name=default}  parameter with a default value
#   {selection}     code selected when the template was inserted
#   |CURSOR|        caret position after expansion
#   \t              one indent level (converted to spaces if needed)

const CURSOR = "CURSOR"
const SELECTION = "selection"
const PLACEHOLDER_PATTERN = "\\|CURSOR\\||\\{([A-Za-z_][A-Za-z0-9_]*)(?:=([^{}\\n]*))?\\}"

# words separated by spaces, "quoted text" is one word
const ARGS_PATTERN = "\"([^\"]*)\"?|\\S+"

static var _regex: RegEx
static var _args_regex: RegEx

static func _get_regex() -> RegEx:
	if _regex == null:
		_regex = RegEx.create_from_string(PLACEHOLDER_PATTERN)
	return _regex

# splits "keyword value \"value with spaces\"" into [{raw, value, start, quoted}],
# an unclosed quote runs to the end of the text
static func split_args(text: String) -> Array[Dictionary]:
	if _args_regex == null:
		_args_regex = RegEx.create_from_string(ARGS_PATTERN)
	var args: Array[Dictionary] = []
	for result in _args_regex.search_all(text):
		var quoted = result.get_start(1) != -1
		args.append({
			"raw": result.get_string(),
			"value": result.get_string(1) if quoted else result.get_string(),
			"start": result.get_start(),
			"quoted": quoted,
		})
	return args

# unique parameter names in order of first appearance, without {selection}
static func get_params(body: String) -> PackedStringArray:
	var params = PackedStringArray()
	for result in _get_regex().search_all(body):
		var param_name = result.get_string(1)
		if _is_param(param_name) and not params.has(param_name):
			params.append(param_name)
	return params

# parameter name -> default value, the first default of a parameter wins
static func get_defaults(body: String) -> Dictionary:
	var defaults = {}
	for result in _get_regex().search_all(body):
		var param_name = result.get_string(1)
		if _is_param(param_name) and result.get_start(2) != -1 and not defaults.has(param_name):
			defaults[param_name] = result.get_string(2)
	return defaults

static func uses_selection(body: String) -> bool:
	for result in _get_regex().search_all(body):
		if result.get_string(1) == SELECTION:
			return true
	return false

static func _is_param(param_name: String) -> bool:
	return not param_name.is_empty() and param_name != CURSOR and param_name != SELECTION

static func get_preview(body: String, values: Array = [], selection: String = "") -> String:
	return expand(body, values, "", "\t", selection).text

# returns {text, cursor, cursor_order, stops} - stops are params without a value: [{name, offset, length}]
# cursor_order is the position of |CURSOR| among the stops (-0.5 before the first one, 0.5 between the first and the second, ...)
# a param without a value is filled with its default (or its name) and becomes a tab stop
static func expand(body: String, values: Array = [], indent: String = "", indent_unit: String = "\t", selection: String = "") -> Dictionary:
	var params = get_params(body)
	var defaults = get_defaults(body)
	var source = _apply_indentation(body, indent, indent_unit)

	var text = ""
	var stops: Array[Dictionary] = []
	var cursor = -1
	var cursor_order = 0.0
	var last_end = 0

	for result in _get_regex().search_all(source):
		text += source.substr(last_end, result.get_start() - last_end)
		last_end = result.get_end()

		var param_name = result.get_string(1)
		if param_name.is_empty() or param_name == CURSOR:
			if cursor == -1:
				cursor = text.length()
				cursor_order = stops.size() - 0.5
			continue
		if param_name == SELECTION:
			text += _indent_lines(selection, _line_indent(text))
			continue

		var index = params.find(param_name)
		if index < values.size():
			text += str(values[index])
		else:
			var placeholder: String = defaults.get(param_name, param_name)
			stops.append({"name": param_name, "offset": text.length(), "length": placeholder.length()})
			text += placeholder

	text += source.substr(last_end)
	if cursor == -1:
		cursor = text.length()
		cursor_order = stops.size() - 0.5

	return {"text": text, "stops": stops, "cursor": cursor, "cursor_order": cursor_order}

# leading whitespace of the last line of text
static func _line_indent(text: String) -> String:
	var line = text.substr(text.rfind("\n") + 1)
	return line.substr(0, line.length() - line.strip_edges(true, false).length())

# indents all lines except the first one, empty lines stay empty
static func _indent_lines(text: String, indent: String) -> String:
	var lines = text.split("\n")
	for i in range(1, lines.size()):
		if not lines[i].strip_edges().is_empty():
			lines[i] = indent + lines[i]
	return "\n".join(lines)

# removes the indentation shared by all non-empty lines
static func dedent(text: String) -> String:
	var lines = text.split("\n")
	var common = ""
	var first = true
	for line in lines:
		if line.strip_edges().is_empty():
			continue
		var line_indent = line.substr(0, line.length() - line.strip_edges(true, false).length())
		if first:
			common = line_indent
			first = false
		else:
			var i = 0
			while i < common.length() and i < line_indent.length() and common[i] == line_indent[i]:
				i += 1
			common = common.substr(0, i)
	for i in lines.size():
		lines[i] = lines[i].substr(common.length()) if lines[i].begins_with(common) else lines[i].strip_edges(true, false)
	return "\n".join(lines)

# indents all lines except the first one
static func _apply_indentation(body: String, indent: String, indent_unit: String) -> String:
	var lines = body.split("\n")
	for i in range(lines.size()):
		var line = lines[i]
		var tabs = 0
		while tabs < line.length() and line[tabs] == "\t":
			tabs += 1
		line = indent_unit.repeat(tabs) + line.substr(tabs)
		if i > 0 and not line.is_empty():
			line = indent + line
		lines[i] = line
	return "\n".join(lines)
