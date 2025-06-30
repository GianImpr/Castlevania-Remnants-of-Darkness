####################################################################################
##                        This file is part of GDTerminal.                        ##
##                https://github.com/ProgrammerOnCoffee/GDTerminal                ##
####################################################################################
## Copyright (c) 2025 ProgrammerOnCoffee.                                         ##
##                                                                                ##
## Permission is hereby granted, free of charge, to any person obtaining a copy   ##
## of this software and associated documentation files (the "Software"), to deal  ##
## in the Software without restriction, including without limitation the rights   ##
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      ##
## copies of the Software, and to permit persons to whom the Software is          ##
## furnished to do so, subject to the following conditions:                       ##
##                                                                                ##
## The above copyright notice and this permission notice shall be included in all ##
## copies or substantial portions of the Software.                                ##
##                                                                                ##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     ##
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       ##
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    ##
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         ##
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  ##
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  ##
## SOFTWARE.                                                                      ##
####################################################################################

@tool
extends EditorPlugin

## The plugin dock.
var dock: BoxContainer
## The run hotkey, as returned by [method InputEvent.as_text].
var run_hotkey := "Ctrl+Alt+Kp Enter"

## The [CodeEdit] that holds code.
var code_edit: CodeEdit
## The [Button] that opens the list of saved commands.
var saved_button: Button
## The [Button] that runs the code.
var run_button: Button
## The [Button] that expands [member code_edit] when toggled.
var expand_button: Button
## The [Panel] that holds the settings window.
var settings_panel: Panel
## The [VBoxContainer] that holds settings.
var settings_vbox: VBoxContainer
## The editor's theme, as returned by [method EditorInterface.get_editor_theme].
var theme := EditorInterface.get_editor_theme()

## If [code]true[/code], the user is selecting a new run hotkey.
var _is_selecting_new_run_hotkey := false
## The last [enum DockSlot] that the plugin was in.[br]
## Used to restore the plugin dock to the correct slot
## after moving it out of the bottom panel.
var _dock_slot := DOCK_SLOT_LEFT_BR
## If [code]true[/code], the dock is in the bottom panel.
var _is_in_bottom_panel := false:
	set(value):
		if value != _is_in_bottom_panel:
			dock.custom_minimum_size.y = 192.0 if value else 256.0
			dock.vertical = not value
			code_edit.gutters_draw_line_numbers = value and EditorInterface.get_editor_settings().get_setting(
					"text_editor/appearance/gutters/show_line_numbers")
			run_button.text = "" if value else "Run"
			run_button.size_flags_horizontal = Control.SIZE_EXPAND if value else Control.SIZE_EXPAND_FILL
			expand_button.visible = not value
			var buttons := dock.get_node(^"Buttons") as BoxContainer
			buttons.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if value else Control.SIZE_FILL
			buttons.vertical = value
			
			var saved_panel := dock.get_node(^"Control/Saved") as Panel
			var settings_pressed: bool = buttons.get_node(^"Settings").button_pressed
			var saved_pressed := saved_button.button_pressed
			if value:
				code_edit.anchor_left = 0.0
				code_edit.anchor_right = 1.0
				code_edit.anchor_top = -1.0 if settings_pressed or saved_pressed else 0.0
				code_edit.anchor_bottom = 0.0 if settings_pressed or saved_pressed else 1.0
				settings_panel.anchor_left = 0.0
				settings_panel.anchor_right = 1.0
				settings_panel.anchor_top = 0.0 if settings_pressed else 1.0
				settings_panel.anchor_bottom = 1.0 if settings_pressed else 2.0
				saved_panel.anchor_left = 0.0
				saved_panel.anchor_right = 1.0
				saved_panel.anchor_top = 0.0 if saved_pressed else 1.0
				saved_panel.anchor_bottom = 1.0 if saved_pressed else 2.0
			else:
				code_edit.anchor_top = 0.0
				code_edit.anchor_bottom = 1.0
				code_edit.anchor_left = 1.0 if settings_pressed or saved_pressed else 0.0
				code_edit.anchor_right = 2.0 if settings_pressed or saved_pressed else 1.0
				settings_panel.anchor_top = 0.0
				settings_panel.anchor_bottom = 1.0
				settings_panel.anchor_left = 0.0 if settings_pressed else -1.0
				settings_panel.anchor_right = 1.0 if settings_pressed else 0.0
				saved_panel.anchor_top = 0.0
				saved_panel.anchor_bottom = 1.0
				saved_panel.anchor_left = 0.0 if saved_pressed else -1.0
				saved_panel.anchor_right = 1.0 if saved_pressed else 0.0
			
			_is_in_bottom_panel = value
## The value of the Clear on Run setting.
var _clear_on_run := false
## The value of the Print on Run setting.
var _print_on_run := false
## The value of the Print Execution Time setting.
var _print_execution_time := false
## The value of the Mark Scene as Unsaved setting.
var _mark_unsaved := false
## The value of the Expand Factor setting.
var _expand_factor := 2.5


func _enter_tree() -> void:
	dock = load("res://addons/GDTerminal/dock.tscn").instantiate()
	code_edit = dock.get_node(^"Control/CodeEdit") as CodeEdit
	settings_panel = dock.get_node(^"Control/Settings") as Panel
	settings_vbox = settings_panel.get_node(^"ScrollContainer/VBoxContainer") as VBoxContainer
	var buttons := dock.get_node(^"Buttons") as BoxContainer
	## The [Button] that toggles the settings panel when pressed.
	var settings_button := buttons.get_node(^"Settings") as Button
	saved_button = buttons.get_node(^"Saved") as Button
	run_button = buttons.get_node(^"Run")
	## The [Button] that clears [member code_edit].
	var clear_button := buttons.get_node(^"Clear") as Button
	expand_button = buttons.get_node(^"Expand") as Button
	## The [Button] that moves the dock to the bottom panel.
	var bottom_button := settings_vbox.get_node(^"MoveToBottom") as Button
	
	# Set button icons
	run_button.icon = theme.get_icon(&"Play", &"EditorIcons")
	saved_button.icon = theme.get_icon(&"Save", &"EditorIcons")
	clear_button.icon = theme.get_icon(&"Clear", &"EditorIcons")
	expand_button.icon = theme.get_icon(&"MoveRight", &"EditorIcons")
	settings_button.icon = theme.get_icon(&"GDScript", &"EditorIcons")
	run_button.get_child(0).self_modulate = theme.get_color(&"accent_color", &"Editor")
	bottom_button.icon = theme.get_icon(&"ControlAlignBottomWide", &"EditorIcons")
	bottom_button.toggled.connect(_on_move_to_bottom_toggled)
	
	saved_button.toggled.connect(func(toggled_on: bool) -> void:
		if toggled_on:
			settings_button.disabled = true
			expand_button.disabled = true
			clear_button.disabled = true
			run_button.disabled = true
		var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		var saved_panel := dock.get_node(^"Control/Saved")
		tween.tween_property(saved_panel, ^":modulate:a", 1.0 if toggled_on else 0.5, 0.75)
		tween.tween_property(code_edit, ^":self_modulate:a", 0.5 if toggled_on else 1.0, 0.75)
		if _is_in_bottom_panel:
			tween.tween_property(saved_panel, ^":anchor_top", 0.0 if toggled_on else 1.0, 0.75)
			tween.tween_property(saved_panel, ^":anchor_bottom", 1.0 if toggled_on else 2.0, 0.75)
			tween.tween_property(code_edit, ^":anchor_top", -1.0 if toggled_on else 0.0, 0.75)
			tween.tween_property(code_edit, ^":anchor_bottom", 0.0 if toggled_on else 1.0, 0.75)
		else:
			tween.tween_property(saved_panel, ^":anchor_left", 0.0 if toggled_on else -1.0, 0.75)
			tween.tween_property(saved_panel, ^":anchor_right", 1.0 if toggled_on else 0.0, 0.75)
			tween.tween_property(code_edit, ^":anchor_left", 1.0 if toggled_on else 0.0, 0.75)
			tween.tween_property(code_edit, ^":anchor_right", 2.0 if toggled_on else 1.0, 0.75)
		if not toggled_on:
			await tween.finished
			run_button.disabled = false
			clear_button.disabled = false
			expand_button.disabled = false
			settings_button.disabled = false
			for command in saved_panel.get_node(
					^"VBoxContainer/ScrollContainer/VBoxContainer").get_children():
				if command.is_deleted:
					command.queue_free()
	)
	settings_button.toggled.connect(func(toggled_on: bool) -> void:
		if toggled_on:
			saved_button.disabled = true
			clear_button.disabled = true
			expand_button.disabled = true
		var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
		tween.tween_property(settings_panel, ^":modulate:a", 1.0 if toggled_on else 0.5, 0.75)
		tween.tween_property(code_edit, ^":self_modulate:a", 0.5 if toggled_on else 1.0, 0.75)
		if _is_in_bottom_panel:
			tween.tween_property(settings_panel, ^":anchor_top", 0.0 if toggled_on else 1.0, 0.75)
			tween.tween_property(settings_panel, ^":anchor_bottom", 1.0 if toggled_on else 2.0, 0.75)
			tween.tween_property(code_edit, ^":anchor_top", -1.0 if toggled_on else 0.0, 0.75)
			tween.tween_property(code_edit, ^":anchor_bottom", 0.0 if toggled_on else 1.0, 0.75)
		else:
			tween.tween_property(settings_panel, ^":anchor_left", 0.0 if toggled_on else -1.0, 0.75)
			tween.tween_property(settings_panel, ^":anchor_right", 1.0 if toggled_on else 0.0, 0.75)
			tween.tween_property(code_edit, ^":anchor_left", 1.0 if toggled_on else 0.0, 0.75)
			tween.tween_property(code_edit, ^":anchor_right", 2.0 if toggled_on else 1.0, 0.75)
		if not toggled_on:
			await tween.finished
			expand_button.disabled = false
			clear_button.disabled = false
			saved_button.disabled = false
	)
	settings_vbox.get_node(^"RunHotkey/Button").pressed.connect(func() -> void:
		var button := settings_vbox.get_node(^"RunHotkey/Button") as Button
		button.text = "Press Key(s)"
		run_button.disabled = true
		_is_selecting_new_run_hotkey = true
		await button.mouse_exited
		_is_selecting_new_run_hotkey = false
		run_button.disabled = false
		button.text = run_hotkey
	)
	
	## Calls [method set] with the arguments reversed.
	var seti := func(value: Variant, property: StringName) -> void:
		set(property, value)
	settings_vbox.get_node(^"ClearOnRun").toggled.connect(seti.bind(&"_clear_on_run"))
	settings_vbox.get_node(^"PrintOnRun").toggled.connect(seti.bind(&"_print_on_run"))
	settings_vbox.get_node(^"PrintExecutionTime").toggled.connect(seti.bind(&"_print_execution_time"))
	settings_vbox.get_node(^"MarkUnsaved").toggled.connect(seti.bind(&"_mark_unsaved"))
	
	# Expand/collapse
	dock.get_node(^"Control").resized.connect(func() -> void:
		if expand_button.button_pressed:
			code_edit.global_position = dock.global_position
			code_edit.size = dock.get_node(^"Control").size * Vector2(_expand_factor, 1.0)
	, CONNECT_DEFERRED)
	expand_button.toggled.connect(func(toggled_on: bool) -> void:
		if toggled_on:
			saved_button.disabled = true
			settings_button.disabled = true
			code_edit.set_deferred(&"global_position", code_edit.global_position)
			code_edit.top_level = true
			create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).tween_property(
					code_edit, ^":size:x", settings_panel.size.x * _expand_factor, 0.5)
			expand_button.icon = theme.get_icon(&"MoveLeft", &"EditorIcons")
			expand_button.tooltip_text = "Collapse the CodeEdit."
		else:
			expand_button.tooltip_text = "Expand the CodeEdit."
			expand_button.icon = theme.get_icon(&"MoveRight", &"EditorIcons")
			await create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).tween_property(
					code_edit, ^":size", settings_panel.size, 0.5).finished
			code_edit.top_level = false
			code_edit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			settings_button.disabled = false
			saved_button.disabled = false
	)
	
	# GDScriptSyntaxHighlighter was only exposed to EditorPlugins in v4.4
	if ClassDB.can_instantiate(&"GDScriptSyntaxHighlighter"):
		code_edit.syntax_highlighter = ClassDB.instantiate(&"GDScriptSyntaxHighlighter")
	else:
		# Compatability for versions < 4.4
		# Attempt to get a GDScriptSyntaxHighlighter from an open script editor
		var script_editor := EditorInterface.get_script_editor()
		for open_script_editor in script_editor.get_open_script_editors():
			# Get the open script editor's syntax highlighter
			var syntax_highlighter: SyntaxHighlighter = open_script_editor.get_base_editor().syntax_highlighter
			if syntax_highlighter.is_class("GDScriptSyntaxHighlighter"):
				code_edit.syntax_highlighter = syntax_highlighter
		
		# Attempt to get a GDScriptSyntaxHighlighter whenever the script is changed
		if not code_edit.syntax_highlighter:
			script_editor.editor_script_changed.connect(_on_editor_script_changed)
	
	#region Adjust to theme
	# Adjust CodeEdit based on user's script editor settings
	var editor_settings := EditorInterface.get_editor_settings()
	code_edit.caret_type = editor_settings.get_setting(
			"text_editor/appearance/caret/type")
	code_edit.caret_blink = editor_settings.get_setting(
			"text_editor/appearance/caret/caret_blink")
	code_edit.caret_blink_interval = editor_settings.get_setting(
			"text_editor/appearance/caret/caret_blink_interval")
	code_edit.caret_move_on_right_click = editor_settings.get_setting(
			"text_editor/behavior/navigation/move_caret_on_right_click")
	code_edit.draw_tabs = editor_settings.get_setting(
			"text_editor/appearance/whitespace/draw_tabs")
	code_edit.draw_spaces = editor_settings.get_setting(
			"text_editor/appearance/whitespace/draw_spaces")
	code_edit.gutters_zero_pad_line_numbers = editor_settings.get_setting(
			"text_editor/appearance/gutters/line_numbers_zero_padded")
	code_edit.highlight_current_line = editor_settings.get_setting(
			"text_editor/appearance/caret/highlight_current_line")
	code_edit.highlight_all_occurrences = editor_settings.get_setting(
			"text_editor/appearance/caret/highlight_all_occurrences")
	code_edit.auto_brace_completion_enabled = editor_settings.get_setting(
			"text_editor/completion/auto_brace_complete")
	code_edit.add_theme_font_size_override(&"font_size",
			editor_settings.get_setting("interface/editor/code_font_size"))
	code_edit.add_theme_color_override(&"font_color",
			editor_settings.get_setting("text_editor/theme/highlighting/text_color"))
	code_edit.add_theme_color_override(&"caret_color",
			editor_settings.get_setting("text_editor/theme/highlighting/caret_color"))
	#endregion Adjust to theme
	
	run_button.pressed.connect(func() -> void:
		run(code_edit.text))
	clear_button.pressed.connect(code_edit.clear)
	
	# Save current code sample
	dock.get_node(^"Control/Saved/VBoxContainer/Button"
			).pressed.connect(func() -> void:
		if code_edit.text:
			add_saved_command("New Command", code_edit.text))
	
	if FileAccess.file_exists("res://addons/GDTerminal/data.cfg"):
		var config := ConfigFile.new()
		if not config.load("res://addons/GDTerminal/data.cfg"):
			code_edit.text = config.get_value("data", "command", "")
			for command in config.get_value("data", "saved_commands", []):
				add_saved_command(command[0], command[1])
			_is_in_bottom_panel = config.get_value("data", "is_in_bottom", _is_in_bottom_panel)
			
			_clear_on_run = config.get_value("settings", "clear_on_run", _clear_on_run)
			_print_on_run = config.get_value("settings", "print_on_run", _print_on_run)
			_print_execution_time = config.get_value("settings", "print_execution_time", _print_execution_time)
			_mark_unsaved = config.get_value("settings", "mark_unsaved", _mark_unsaved)
			_expand_factor = config.get_value("settings", "expand_factor", _expand_factor)
			
			run_hotkey = config.get_value("hotkeys", "run_hotkey", run_hotkey)
			var event_key: InputEventKey = run_button.shortcut.events[0]
			event_key.keycode = config.get_value("hotkeys", "run_hotkey_keycode", 4194310)
			event_key.alt_pressed = config.get_value("hotkeys", "run_hotkey_alt_pressed", true)
			event_key.ctrl_pressed = config.get_value("hotkeys", "run_hotkey_ctrl_pressed", true)
			event_key.meta_pressed = config.get_value("hotkeys", "run_hotkey_meta_pressed", false)
			event_key.shift_pressed = config.get_value("hotkeys", "run_hotkey_shift_pressed", false)
	
	settings_vbox.get_node(^"ClearOnRun").set_pressed_no_signal(_clear_on_run)
	settings_vbox.get_node(^"PrintOnRun").set_pressed_no_signal(_print_on_run)
	settings_vbox.get_node(^"PrintExecutionTime").set_pressed_no_signal(_print_execution_time)
	settings_vbox.get_node(^"MarkUnsaved").set_pressed_no_signal(_mark_unsaved)
	settings_vbox.get_node(^"RunHotkey/Button").text = run_hotkey
	settings_vbox.get_node(^"ExpandFactor/SpinBox").set_value_no_signal(_expand_factor)
	settings_vbox.get_node(^"MoveToBottom").set_pressed_no_signal(_is_in_bottom_panel)
	
	if _is_in_bottom_panel:
		add_control_to_bottom_panel(dock, "GDTerminal")
	else:
		add_control_to_dock(_dock_slot, dock)
		# set_dock_tab_icon was introduced in 4.3
		# Check engine version for compatability with earlier versions
		if Engine.get_version_info().major > 4 or Engine.get_version_info().minor > 2:
			call(&"set_dock_tab_icon", dock, load("res://addons/GDTerminal/icon.png"))


func _exit_tree() -> void:
	if _is_in_bottom_panel:
		remove_control_from_bottom_panel(dock)
	else:
		remove_control_from_docks(dock)
	
	#region Save data
	var config := ConfigFile.new()
	config.set_value("data", "command", code_edit.text)
	var saved_commands := []
	for command: SavedCommand in dock.get_node(
			^"Control/Saved/VBoxContainer/ScrollContainer/VBoxContainer").get_children():
		saved_commands.append([command.line_edit.text, command.code])
	config.set_value("data", "saved_commands", saved_commands)
	config.set_value("data", "is_in_bottom", _is_in_bottom_panel)
	
	config.set_value("settings", "clear_on_run", _clear_on_run)
	config.set_value("settings", "print_on_run", _clear_on_run)
	config.set_value("settings", "print_execution_time", _print_execution_time)
	config.set_value("settings", "mark_scene_as_unsaved", _mark_unsaved)
	config.set_value("settings", "expand_factor", _expand_factor)
	
	config.set_value("hotkeys", "run_hotkey", run_hotkey)
	var input_event_key: InputEventKey = run_button.shortcut.events[0]
	config.set_value("hotkeys", "run_hotkey_keycode", input_event_key.keycode)
	config.set_value("hotkeys", "run_hotkey_alt_pressed", input_event_key.alt_pressed)
	config.set_value("hotkeys", "run_hotkey_ctrl_pressed", input_event_key.ctrl_pressed)
	config.set_value("hotkeys", "run_hotkey_meta_pressed", input_event_key.meta_pressed)
	config.set_value("hotkeys", "run_hotkey_shift_pressed", input_event_key.shift_pressed)
	config.save("res://addons/GDTerminal/data.cfg")
	#endregion Save data
	
	dock.free()


func _unhandled_key_input(event: InputEvent) -> void:
	var event_key := event as InputEventKey
	if event_key and event_key.pressed:
		if code_edit.has_focus():
			if event_key.keycode == KEY_K and event_key.is_command_or_control_pressed():
				# Comment selected lines
				var lines := PackedInt32Array()
				# Get selected lines of each caret
				for i in code_edit.get_caret_count():
					var from_line := code_edit.get_selection_from_line(i)
					var to_line := code_edit.get_selection_to_line(i)
					for j in to_line - from_line + 1:
						var line := from_line + j
						if line not in lines:
							lines.append(line)
				
				for i in lines:
					# If line is not already commented
					if code_edit.is_in_comment(i) == -1:
						# Comment all lines
						for j in lines:
							var line_j := code_edit.get_line(j)
							# Get index of first key that isn't a space or tab
							var index := 0
							for letter in line_j:
								if letter != "\t" and letter != " ":
									break
								index += 1
							code_edit.set_line(j, line_j.substr(0, index) + "#" + line_j.substr(index))
						
						# Shift all carets
						for j in code_edit.get_caret_count():
							code_edit.set_caret_column(code_edit.get_caret_column(j) + 1, true, j)
							code_edit.set_selection_origin_column(
									code_edit.get_selection_origin_column(j) + 1, j)
						return
				
				# Shift all carets
				for j in code_edit.get_caret_count():
					code_edit.set_caret_column(code_edit.get_caret_column(j) - 1, true, j)
					code_edit.set_selection_origin_column(
							code_edit.get_selection_origin_column(j) - 1, j)
				# Uncomment all lines
				for j in lines:
					var line_j := code_edit.get_line(j)
					var delimiter_index := line_j.find("#")
					code_edit.set_line(j, line_j.substr(0, delimiter_index) + line_j.substr(delimiter_index + 1))
			else:
				var keycode := event_key.get_keycode_with_modifiers()
				if keycode == KEY_MASK_ALT + KEY_UP:
					code_edit.move_lines_up()
				elif keycode == KEY_MASK_ALT + KEY_DOWN:
					code_edit.move_lines_down()
				elif keycode == KEY_MASK_CTRL + KEY_MASK_ALT + KEY_DOWN:
					code_edit.duplicate_lines()
				elif keycode == KEY_MASK_CTRL + KEY_MASK_SHIFT + KEY_D:
					code_edit.duplicate_selection()
		elif _is_selecting_new_run_hotkey:
			# Set run hotkey to new key(s) pressed.
			run_hotkey = event_key.as_text()
			settings_vbox.get_node(^"RunHotkey/Button").text = run_hotkey
			
			# Update [member run_button]'s shortcut.
			var run_event := run_button.shortcut.events[0] as InputEventKey
			run_event.keycode = event_key.keycode
			run_event.alt_pressed = event_key.alt_pressed
			run_event.ctrl_pressed = event_key.ctrl_pressed
			run_event.meta_pressed = event_key.meta_pressed
			run_event.shift_pressed = event_key.shift_pressed


## Runs [param code].
func run(code: String, is_saved_command := false) -> void:
	if not code:
		return
	
	# If a scene is open, run code under the scene's root node.
	var root := EditorInterface.get_edited_scene_root()
	if not root:
		# Otherwise, run code under the root window.
		root = get_tree().get_root()
	
	# Provide visual feedback to the user that the command has been run.
	#region Visual feedback
	var texture_rect: TextureRect = run_button.get_child(0).duplicate()
	texture_rect.texture = texture_rect.texture.duplicate()
	var gradient: Gradient = texture_rect.texture.gradient.duplicate()
	texture_rect.texture.gradient = gradient
	texture_rect.show()
	var set_offset = func(offset: float):
		gradient.set_offset(2, offset)
		gradient.set_offset(1, offset - 1.0)
		gradient.set_offset(0, offset - 2.0)
	run_button.add_child(texture_rect)
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_method(set_offset, 0.0, 3.0, 0.5)
	tween.tween_callback(texture_rect.queue_free)
	#endregion Visual feedback
	
	#region Create script
	var script := GDScript.new()
	script.source_code = "@tool\nextends Node\nfunc _ready() -> void:"
	if _print_on_run:
		script.source_code += '\n\tprint("\\n--- Begin GDTerminal Output ---\\n")'
	if _print_execution_time:
		script.source_code += "\n\tvar _command_begin_time := Time.get_ticks_usec()"
	
	# Add prefix if one exists
	var prefix: String
	for command: SavedCommand in dock.get_node(
			^"Control/Saved/VBoxContainer/ScrollContainer/VBoxContainer").get_children():
		if command.line_edit.text == "Prefix":
			prefix = command.code
			break
	if prefix:
		script.source_code += "\n\t" + "\n\t".join(prefix.split("\n"))
	script.source_code += "\n\t" + "\n\t".join(code.split("\n"))
	
	if _print_on_run:
		script.source_code += '\n\tprint("\\n--- End GDTerminal Output ---\\n")'
	if _print_execution_time:
		script.source_code += '\n\tvar _command_end_time := Time.get_ticks_usec()\n\tprint("\\n--- Execution Time: %s ms ---\\n" % String.num((_command_end_time - _command_begin_time) * 0.001, 3).pad_decimals(3))'
	script.source_code += "\n\tqueue_free()"
	script.reload()
	#endregion Create script
	
	# Create the node parented to the scene root.
	var node := Node.new()
	node.name = "GDTerminalExecutor"
	node.set_script(script)
	root.add_child(node, false, INTERNAL_MODE_BACK)
	
	if _clear_on_run and not is_saved_command:
		code_edit.clear()
	if _mark_unsaved:
		EditorInterface.mark_scene_as_unsaved()


## Adds a command to the saved commands list.
func add_saved_command(title: String, code: String) -> void:
	var command := SavedCommand.new(title)
	command.code = code
	command.run_button.pressed.connect(run.bind(code, true))
	command.load_button.pressed.connect(code_edit.set.bind(&"text", code))
	# Close saved commands panel when loading a command
	command.load_button.pressed.connect(saved_button.set.bind(&"button_pressed", false))
	dock.get_node(^"Control/Saved/VBoxContainer/ScrollContainer/VBoxContainer").add_child(command)


func _on_move_to_bottom_toggled(toggled_on: bool) -> void:
	if toggled_on:
		var current_slot = get(StringName(dock.get_parent().name.to_snake_case().to_upper()))
		# current_slot will be null before v4.3 because the
		# dock parent's name will not equal the dock slot
		if current_slot:
			_dock_slot = current_slot
		remove_control_from_docks(dock)
		add_control_to_bottom_panel(dock, "GDTerminal")
		make_bottom_panel_item_visible.call_deferred(dock)
	else:
		remove_control_from_bottom_panel(dock)
		add_control_to_dock(_dock_slot, dock)
		# set_dock_tab_icon was introduced in 4.3
		# Check engine version for compatability with earlier versions
		if Engine.get_version_info().major > 4 or Engine.get_version_info().minor > 2:
			call(&"set_dock_tab_icon", dock, load("res://addons/GDTerminal/icon.png"))
		(dock.get_parent() as TabContainer).current_tab = dock.get_index()
	_is_in_bottom_panel = toggled_on


func _on_editor_script_changed(_script: Script) -> void:
	var script_editor := EditorInterface.get_script_editor()
	var base_editor := script_editor.get_current_editor().get_base_editor() as CodeEdit
	if base_editor:
		var syntax_highlighter := base_editor.syntax_highlighter
		if syntax_highlighter.is_class("GDScriptSyntaxHighlighter"):
			code_edit.syntax_highlighter = syntax_highlighter
			script_editor.editor_script_changed.disconnect(_on_editor_script_changed)


## Represents a saved command in the saved commands screen.
class SavedCommand:
	extends HBoxContainer
	
	## The editor's theme, as returned by [method EditorInterface.get_editor_theme].
	static var editor_theme := EditorInterface.get_editor_theme()
	
	## The [LineEdit] that hoolds the command's name.
	var line_edit := LineEdit.new()
	## The [Button] that will run the command when pressed.
	var run_button := Button.new()
	## The [Button] that will load the command into the main [CodeEdit] when pressed.
	var load_button := Button.new()
	## The [Button] that will mark the command as deleted when pressed.
	var delete_button := Button.new()
	
	## The command's code.
	var code: String
	## If [code]true[/code], the command is currently marked as deleted
	## and will be freed when the saved commands panel is closed.
	var is_deleted := false
	
	
	func _init(title: String) -> void:
		line_edit.placeholder_text = "Command Name"
		line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line_edit.text = title
		add_child(line_edit)
		run_button.icon = editor_theme.get_icon(&"Play", &"EditorIcons")
		run_button.tooltip_text = "Run this command."
		add_child(run_button)
		load_button.icon = editor_theme.get_icon(&"Load", &"EditorIcons")
		load_button.tooltip_text = "Load this command into CodeEdit.\nExisting code will be cleared."
		add_child(load_button)
		delete_button.icon = editor_theme.get_icon(&"Remove", &"EditorIcons")
		delete_button.tooltip_text = "Delete this command."
		delete_button.pressed.connect(_on_delete_pressed)
		add_child(delete_button)
	
	
	func _on_delete_pressed() -> void:
		if is_deleted:
			is_deleted = false
			line_edit.editable = true
			run_button.disabled = false
			load_button.disabled = false
			delete_button.icon = editor_theme.get_icon(&"Remove", &"EditorIcons")
			delete_button.tooltip_text = "Delete this command."
		else:
			is_deleted = true
			line_edit.editable = false
			run_button.disabled = true
			load_button.disabled = true
			delete_button.icon = editor_theme.get_icon(&"UndoRedo", &"EditorIcons")
			delete_button.tooltip_text = "Recover this command."
