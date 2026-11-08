@tool
extends RefCounted

# Tab stops after expansion. Tab copies the value to other occurrences of the
# parameter and selects the next one, Shift+Tab the previous one, the last Tab jumps to |CURSOR|.
# Ends when the caret leaves the parameter (the value is still copied) or the line count changes.

var text_edit: TextEdit
var active: bool = false

var _stops: Array[Dictionary] = []  # {name, line, column, length, order}
var _primary: Array[int] = []       # first occurrence of each parameter
var _cursor: Dictionary             # final caret position
var _current: int = -1
var _line_count: int = 0
var _line_length: int = 0

func _init(p_text_edit: TextEdit, expanded: Dictionary, start_line: int, start_column: int):
	text_edit = p_text_edit
	var text: String = expanded.text

	for stop in expanded.stops:
		var pos = _offset_to_position(text, stop.offset, start_line, start_column)
		if not _stops.any(func(s): return s.name == stop.name):
			_primary.append(_stops.size())
		_stops.append({"name": stop.name, "line": pos.x, "column": pos.y, "length": stop.length, "order": _stops.size()})

	var cursor_pos = _offset_to_position(text, expanded.cursor, start_line, start_column)
	_cursor = {"name": "", "line": cursor_pos.x, "column": cursor_pos.y, "length": 0, "order": expanded.cursor_order}
	_stops.append(_cursor)

func start() -> void:
	if _primary.is_empty():
		_move_to_cursor()
		return
	active = true
	_current = 0
	_select_current()
	text_edit.caret_changed.connect(_on_caret_changed)

# returns true when Tab was consumed
func next() -> bool:
	if not active:
		return false
	if not _is_caret_in_current():
		_stop()
		return false

	_commit_current()
	_current += 1
	if _current >= _primary.size():
		_stop()
		_move_to_cursor()
	else:
		_select_current()
	return true

# returns true when Shift+Tab was consumed
func previous() -> bool:
	if not active:
		return false
	if not _is_caret_in_current():
		_stop()
		return false

	_commit_current()
	_current = maxi(_current - 1, 0)
	_select_current()
	return true

func finish() -> void:
	if active and _is_caret_in_current():
		_commit_current()
	_stop()

func _stop() -> void:
	active = false
	if is_instance_valid(text_edit) and text_edit.caret_changed.is_connected(_on_caret_changed):
		text_edit.caret_changed.disconnect(_on_caret_changed)

# clicking or moving elsewhere ends the session, the typed value still goes to the other occurrences
func _on_caret_changed() -> void:
	if not active or _is_caret_in_current():
		return
	if is_instance_valid(text_edit) and text_edit.get_line_count() == _line_count:
		_commit_current()
	_stop()

static func _offset_to_position(text: String, offset: int, start_line: int, start_column: int) -> Vector2i:
	var before = text.substr(0, offset)
	var newlines = before.count("\n")
	if newlines == 0:
		return Vector2i(start_line, start_column + offset)
	return Vector2i(start_line + newlines, offset - before.rfind("\n") - 1)

func _current_stop() -> Dictionary:
	return _stops[_primary[_current]]

# how much the line changed since the parameter was selected
func _current_delta() -> int:
	return text_edit.get_line(_current_stop().line).length() - _line_length

func _is_caret_in_current() -> bool:
	if not is_instance_valid(text_edit) or text_edit.get_line_count() != _line_count:
		return false
	var stop = _current_stop()
	var end_column = stop.column + stop.length + _current_delta()
	var caret_column = text_edit.get_caret_column()
	return text_edit.get_caret_line() == stop.line and caret_column >= stop.column and caret_column <= end_column

func _select_current() -> void:
	var stop = _current_stop()
	if stop.length == 0:
		# empty default value - nothing to select, just move the caret there
		text_edit.deselect()
		text_edit.set_caret_line(stop.line)
		text_edit.set_caret_column(stop.column)
	else:
		text_edit.select(stop.line, stop.column, stop.line, stop.column + stop.length)
	_line_count = text_edit.get_line_count()
	_line_length = text_edit.get_line(stop.line).length()

func _commit_current() -> void:
	var stop = _current_stop()
	var delta = _current_delta()
	stop.length += delta
	_shift_stops_after(stop, delta)

	var value = text_edit.get_line(stop.line).substr(stop.column, stop.length)
	text_edit.begin_complex_operation()
	for other in _stops:
		if is_same(other, stop) or other.name != stop.name:
			continue
		if other.length == value.length() and text_edit.get_line(other.line).substr(other.column, other.length) == value:
			continue
		var old_length = other.length
		text_edit.remove_text(other.line, other.column, other.line, other.column + old_length)
		if not value.is_empty():
			text_edit.insert_text(value, other.line, other.column)
		other.length = value.length()
		_shift_stops_after(other, value.length() - old_length)
	text_edit.end_complex_operation()

# stops at the same column (after an empty one) are told apart by their order in the text
func _shift_stops_after(changed: Dictionary, delta: int) -> void:
	if delta == 0:
		return
	for stop in _stops:
		if is_same(stop, changed) or stop.line != changed.line:
			continue
		if stop.column > changed.column or (stop.column == changed.column and stop.order > changed.order):
			stop.column += delta

func _move_to_cursor() -> void:
	text_edit.deselect()
	text_edit.set_caret_line(_cursor.line)
	text_edit.set_caret_column(_cursor.column)
