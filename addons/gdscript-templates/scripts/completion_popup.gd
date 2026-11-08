@tool
extends PanelContainer

# Template browser (Ctrl+Space)
# An inline panel inside the script's text edit rather than a popup window:
# no title bar, and no window placement problems with floating editors or multiple screens.

signal template_chosen(keyword: String, params: Array)
signal edit_requested
signal closed

const Settings = preload("res://addons/gdscript-templates/scripts/settings.gd")
const Expander = preload("res://addons/gdscript-templates/scripts/template_expander.gd")

# panel height in script lines, shrinks when the script editor is smaller
const HEIGHT_LINES = 22
# templates in the "Most Used" group
const MOST_USED_COUNT = 5
const UNCATEGORIZED = "Custom"

var _templates: Dictionary = {}
# keyword of each list item, "" for category headers
var _keys: Array[String] = []
var _categories: PackedStringArray = []
# the first word of the search filters the templates, the rest are parameter values
var _query := ""
var _param_count := 0
# picked with the arrows or the mouse, kept while typing parameter values
var _picked_keyword := ""
# code selected in the script, templates with {selection} wrap it
var _selection := ""
# keyword -> how many times it was inserted
var _usage: Dictionary = {}

var _text_edit: TextEdit
# caret line when opened, the panel sits right under it
var _anchor_line := 0

var _search: LineEdit
var _list: ItemList
var _info: Label
var _preview: CodeEdit

func setup(templates: Dictionary, filter: String, selection: String = "", usage: Dictionary = {}, categories: PackedStringArray = []) -> void:
	_templates = templates
	_selection = selection
	_usage = usage
	_categories = categories
	_build()
	_search.text = filter

func _build() -> void:
	var editor_theme = EditorInterface.get_editor_theme()
	var scale = EditorInterface.get_editor_scale()

	var root = VBoxContainer.new()
	add_child(root)

	var top = HBoxContainer.new()
	root.add_child(top)

	_search = LineEdit.new()
	_search.placeholder_text = "Search templates... (keyword param1 \"param 2\")"
	_search.clear_button_enabled = true
	_search.right_icon = editor_theme.get_icon("Search", "EditorIcons")
	_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search.text_changed.connect(func(_text): _on_search_changed())
	_search.text_submitted.connect(func(_text): _choose_selected())
	_search.gui_input.connect(_on_search_gui_input)
	top.add_child(_search)

	var edit_button = _add_button(top, "Edit Templates...", "Edit", "Open the template editor")
	edit_button.pressed.connect(func():
		close()
		edit_requested.emit()
	)
	var close_button = _add_button(top, "", "Close", "Close (Esc)")
	close_button.pressed.connect(close)

	var split = HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(split)

	_list = ItemList.new()
	_list.custom_minimum_size = Vector2(220, 0) * scale
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.size_flags_stretch_ratio = 0.5
	# clicks select without taking the focus, typing continues in the search
	_list.focus_mode = Control.FOCUS_NONE
	_list.item_selected.connect(func(index):
		_picked_keyword = _keys[index]
		_show_preview(index)
	)
	_list.item_activated.connect(func(index):
		if not _keys[index].is_empty():
			_choose(index)
	)
	split.add_child(_list)

	var right = VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.add_child(right)

	_info = Label.new()
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_info)

	_preview = CodeEdit.new()
	_preview.editable = false
	_preview.focus_mode = Control.FOCUS_NONE
	_preview.context_menu_enabled = false
	_preview.custom_minimum_size = Vector2(300, 0) * scale
	_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_preview.syntax_highlighter = Settings.create_gdscript_highlighter()
	right.add_child(_preview)

	var hint = Label.new()
	hint.text = "Enter / Tab: insert     ↑ ↓: select     Esc: close"
	hint.modulate.a = 0.6
	root.add_child(hint)

func _add_button(parent: Control, text: String, icon_name: String, tooltip: String) -> Button:
	var button = Button.new()
	button.text = text
	button.icon = EditorInterface.get_editor_theme().get_icon(icon_name, "EditorIcons")
	button.flat = true
	button.tooltip_text = tooltip
	button.focus_mode = Control.FOCUS_NONE
	parent.add_child(button)
	return button

func _apply_style(text_edit: TextEdit) -> void:
	var scale = EditorInterface.get_editor_scale()
	var editor_theme = EditorInterface.get_editor_theme()
	var style = StyleBoxFlat.new()
	style.bg_color = _opaque_background(text_edit)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = int(10 * scale)
	style.border_color = editor_theme.get_color("accent_color", "Editor")
	style.border_width_left = int(3 * scale)
	style.set_border_width(SIDE_TOP, 1)
	style.set_border_width(SIDE_BOTTOM, 1)
	style.set_content_margin_all(6 * scale)
	style.set_corner_radius_all(int(3 * scale))
	add_theme_stylebox_override("panel", style)

	# same font and zoom as the script
	for control in [_list, _preview]:
		control.add_theme_font_override("font", text_edit.get_theme_font("font"))
		control.add_theme_font_size_override("font_size", text_edit.get_theme_font_size("font_size"))
	_preview.add_theme_color_override("background_color", text_edit.get_theme_color("background_color").lerp(style.bg_color, 0.5))

# solid, like a tooltip: the script editor's background_color is often transparent
static func _opaque_background(text_edit: TextEdit) -> Color:
	var bg = text_edit.get_theme_color("background_color")
	if bg.a < 0.9:
		bg = EditorInterface.get_editor_theme().get_color("base_color", "Editor")
	bg.a = 1.0
	return bg.lightened(0.05)

# opens under the caret line, as a child of the text edit
func open(text_edit: TextEdit) -> void:
	_text_edit = text_edit
	_anchor_line = text_edit.get_caret_line()
	_apply_style(text_edit)
	_refilter()

	text_edit.add_child(self)
	_reposition()
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	text_edit.visibility_changed.connect(_on_text_edit_visibility_changed)

	_search.grab_focus()
	_search.caret_column = _search.text.length()

# restore_focus: give the focus back to the text edit, unless the user moved it elsewhere
func close(restore_focus: bool = true) -> void:
	if is_queued_for_deletion():
		return
	var viewport = get_viewport()
	if viewport and viewport.gui_focus_changed.is_connected(_on_focus_changed):
		viewport.gui_focus_changed.disconnect(_on_focus_changed)
	if is_instance_valid(_text_edit):
		if _text_edit.visibility_changed.is_connected(_on_text_edit_visibility_changed):
			_text_edit.visibility_changed.disconnect(_on_text_edit_visibility_changed)
		if restore_focus and _text_edit.is_visible_in_tree():
			_text_edit.grab_focus()
	closed.emit()
	queue_free()

# keys the search field doesn't handle propagate to the parent text edit,
# stop the ones that would edit the code (Shift+Tab, Ctrl+D, ...), let editor shortcuts through
func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
		return
	if Settings.matches_shortcut(Settings.SHORTCUT_SHOW, event):
		accept_event()
		close()
	elif Settings.matches_shortcut(Settings.SHORTCUT_EXPAND, event):
		accept_event()
	else:
		for action in InputMap.get_actions():
			if action.begins_with("ui_") and event.is_action(action, true):
				accept_event()
				return

func _on_focus_changed(control: Control) -> void:
	if control != self and not is_ancestor_of(control):
		close(false)

# switching to another script hides the text edit
func _on_text_edit_visibility_changed() -> void:
	if not _text_edit.is_visible_in_tree():
		close(false)

# every frame: scrolling and resizing have no single signal to hook
func _process(_delta: float) -> void:
	_reposition()

func _reposition() -> void:
	if not is_instance_valid(_text_edit):
		return
	var edit_size = _text_edit.size
	var line_height = _text_edit.get_line_height()
	var left = float(_text_edit.get_total_gutter_width())
	var right_margin = _text_edit.get_v_scroll_bar().size.x + 6.0
	# width through the minimum size: reset_size() (needed to fit the height) would shrink it to the toolbar
	custom_minimum_size = Vector2(
		maxf(edit_size.x - left - right_margin, 200.0),
		clampf(HEIGHT_LINES * line_height, 150.0, maxf(edit_size.y - line_height * 2, 150.0)))
	size = custom_minimum_size

	# bottom edge of the caret line, (-1, -1) when scrolled out of view
	var line = clampi(_anchor_line, 0, _text_edit.get_line_count() - 1)
	var pos = _text_edit.get_pos_at_line_column(line, 0)
	var y: float
	if pos.y < 0:
		# out of view - stick to the edge the line went past
		y = 0.0 if line < _text_edit.get_first_visible_line() else edit_size.y - size.y
	else:
		y = pos.y + 2.0
		# flip above the line when there's no room below it
		var above = pos.y - line_height - size.y - 2.0
		if y + size.y > edit_size.y and above >= 0:
			y = above
	position = Vector2(left, clampf(y, 0.0, maxf(edit_size.y - size.y, 0.0)))

# typing parameter values keeps the selected template, only the preview changes
func _on_search_changed() -> void:
	var words = _search_words()
	var query = words[0] if words.size() > 0 else ""
	if query != _query or maxi(words.size() - 1, 0) != _param_count:
		_refilter()
	else:
		var selected = _list.get_selected_items()
		if selected.size() > 0:
			_show_preview(selected[0])

func _search_words() -> PackedStringArray:
	return PackedStringArray(Expander.split_args(_search.text).map(func(word): return word.value))

func _params() -> Array:
	return Array(_search_words().slice(1))

func _refilter() -> void:
	var words = _search_words()
	var query = words[0] if words.size() > 0 else ""
	if query != _query:
		_picked_keyword = ""
	_query = query
	_param_count = words.size() - 1 if words.size() > 0 else 0

	_list.clear()
	_keys.clear()
	# nothing typed - all templates by category
	if query.is_empty() and _selection.is_empty():
		_add_grouped()
	else:
		_add_scored(query)

	if _keys.all(func(keyword): return keyword.is_empty()):
		_info.text = "No matching template."
		_info.visible = true
		_preview.text = ""
	else:
		var index = _keys.find(_picked_keyword) if not _picked_keyword.is_empty() else -1
		_select(index if index != -1 else _next_item(0, 1))

# templates that take all the typed values (and wrap the selection) first,
# then by the kind of match (exact, prefix, ...), the most used, how well the keyword matches
func _add_scored(query: String) -> void:
	var scored = []
	for keyword in _templates:
		var entry = _templates[keyword]
		var score = match_score(query, keyword, entry.description + "\n" + entry.category)
		if score >= 0:
			var fits = Expander.get_params(entry.body).size() >= _param_count
			if not _selection.is_empty() and not Expander.uses_selection(entry.body):
				fits = false
			scored.append([1 if fits else 0, match_kind(score), int(_usage.get(keyword, 0)), score, keyword])
	scored.sort_custom(func(a, b):
		for i in 4:
			if a[i] != b[i]:
				return a[i] > b[i]
		return a[4] < b[4]
	)
	for item in scored:
		_add_template(item[4])

func _add_grouped() -> void:
	var used = _usage.keys().filter(func(keyword): return _templates.has(keyword) and int(_usage[keyword]) > 0)
	used.sort_custom(func(a, b): return int(_usage[a]) > int(_usage[b]))
	if not used.is_empty():
		_add_header("Most Used")
		for keyword in used.slice(0, MOST_USED_COUNT):
			_add_template(keyword)

	for category in _categories:
		var keywords = _templates.keys().filter(func(keyword): return _templates[keyword].category == category)
		if keywords.is_empty():
			continue
		_add_header(category if not category.is_empty() else UNCATEGORIZED)
		for keyword in keywords:
			_add_template(keyword)

func _add_header(text: String) -> void:
	_keys.append("")
	var index = _list.add_item(text)
	_list.set_item_selectable(index, false)
	_list.set_item_custom_fg_color(index, EditorInterface.get_editor_theme().get_color("accent_color", "Editor"))

func _add_template(keyword: String) -> void:
	var entry = _templates[keyword]
	var params = Expander.get_params(entry.body)
	var display = keyword
	if not params.is_empty():
		display += "  " + " ".join(Array(params).map(func(p): return "{%s}" % p))
	_keys.append(keyword)
	# indented under the category header
	var index = _list.add_item(("   " if _query.is_empty() and _selection.is_empty() else "") + display)
	var tooltip = entry.description
	if not entry.category.is_empty():
		tooltip += ("\n" if not tooltip.is_empty() else "") + "Category: " + entry.category
	_list.set_item_tooltip(index, tooltip)

# higher is better, -1 = no match
static func match_score(query: String, keyword: String, description: String) -> int:
	if query.is_empty():
		return 0
	var q = query.to_lower()
	var k = keyword.to_lower()
	if k == q:
		return 1000
	if k.begins_with(q):
		return 900 - k.length()
	var index = k.find(q)
	if index != -1:
		return 700 - index
	var gaps = _subsequence_gaps(q, k)
	if gaps != -1:
		return 500 - gaps
	if description.to_lower().contains(q):
		return 100
	return -1

# 4 exact, 3 prefix, 2 contains, 1 fuzzy, 0 description or empty query
static func match_kind(score: int) -> int:
	if score >= 1000:
		return 4
	if score >= 800:
		return 3
	if score >= 600:
		return 2
	if score > 100:
		return 1
	return 0

# number of skipped characters when query chars appear in order, -1 otherwise
static func _subsequence_gaps(query: String, text: String) -> int:
	var pos = 0
	var gaps = 0
	for c in query:
		var found = text.find(c, pos)
		if found == -1:
			return -1
		gaps += found - pos
		pos = found + 1
	return gaps

func _select(index: int) -> void:
	_list.select(index)
	_list.ensure_current_is_visible()
	_show_preview(index)

# first template item from index in the direction (1 or -1), skips headers, -1 when there's none
func _next_item(index: int, direction: int) -> int:
	while index >= 0 and index < _keys.size():
		if not _keys[index].is_empty():
			return index
		index += direction
	return -1

func _move_selection(step: int) -> void:
	var selected = _list.get_selected_items()
	var from = selected[0] if selected.size() > 0 else -1
	var target = clampi(from + step, 0, _keys.size() - 1)
	var direction = 1 if step > 0 else -1
	var index = _next_item(target, direction)
	if index == -1:
		index = _next_item(target, -direction)
	if index == -1:
		return
	_select(index)
	_picked_keyword = _keys[index]

func _show_preview(index: int) -> void:
	var entry = _templates[_keys[index]]
	var info: String = entry.description
	var params = Expander.get_params(entry.body)
	var defaults = Expander.get_defaults(entry.body)
	var values = _params()
	var lines = [] if info.is_empty() else [info]
	if not params.is_empty():
		var described = []
		for i in params.size():
			if i < values.size():
				described.append("%s = %s" % [params[i], values[i]])
			elif defaults.has(params[i]):
				described.append("%s (default: %s)" % [params[i], defaults[params[i]]])
			else:
				described.append(params[i])
		lines.append("Parameters: " + ", ".join(described))
	if not _selection.is_empty():
		lines.append("Wraps the selected code." if Expander.uses_selection(entry.body) else "Replaces the selected code.")
	_info.text = "\n".join(lines)
	_info.visible = not lines.is_empty()
	_preview.text = Expander.get_preview(entry.body, values, _selection)

func _choose(index: int) -> void:
	var keyword = _keys[index]
	var params = _params()
	close()
	template_chosen.emit(keyword, params)

func _choose_selected() -> void:
	var selected = _list.get_selected_items()
	if selected.size() > 0:
		_choose(selected[0])

func _on_search_gui_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_UP:
			_move_selection(-1)
		KEY_DOWN:
			_move_selection(1)
		KEY_PAGEUP:
			_move_selection(-10)
		KEY_PAGEDOWN:
			_move_selection(10)
		KEY_TAB:
			_choose_selected()
		KEY_ESCAPE:
			close()
		_:
			return
	_search.accept_event()
