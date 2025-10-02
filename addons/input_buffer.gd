extends Node
# Keeps track of recent inputs in order to make timing windows more flexible.
# Intended use: Add this file to your project as an Autoload script and have other objects call the class' methods.
# (more on AutoLoad: https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)

# How many milliseconds ahead of time the player can make an input and have it still be recognized.
# I chose the value 150 because it imitates the 9-frame buffer window in the Super Smash Bros. Ultimate game.
var BUFFER_WINDOW: int = 50
# The godot default deadzone is 0.2 so I chose to have it the same
const JOY_DEADZONE: float = 0.2
var COMMAND_HISTORY_DURATION: int = 50

var keyboard_timestamps: Dictionary
var joypad_timestamps: Dictionary
var command_history: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

	# Initialize all dictionary entris.
	keyboard_timestamps = {}
	joypad_timestamps = {}
	command_history = []
	
	
func _process(delta: float) -> void:
	readNewInputs()
	
	const Inputs = {
		"move_left": "b",
		"move_right": "f",
		"up_arrow": "u",
		"crouch": "d",
		"attack": "1",
		"circle": "4",
		"innocent_devil_move": "2",
		"backdash": "l",
		"guard": "r",
		"jump": "3",
		"neutral": "*"
	}
	
	if false:
		var command_string: String = "{"
		for command in command_history:
			command_string += " ["
			for input in command:
				if input["action"] in Inputs.keys():
					command_string += Inputs[input["action"]]
			command_string += "] "
		command_string += "}"
		print(command_string)
		
		
func readNewInputs() -> void:
	if Global.game == null:
		return
		
	var last_actions: Array
	var last_action_names: Array[String]
	var inputs_held: bool = false
	
	if command_history.size() > 0:
		last_actions = command_history.back()
		
	
	if last_actions != null:
		for i in range(0, last_actions.size()):
			last_action_names.append(last_actions[i]["action"])
			if last_actions[i]["action"] != "neutral" and Input.is_action_pressed(last_actions[i]["action"]):
				last_actions[i]["duration"] += 1
				inputs_held = true

	var found_input: bool = false
	var cur_entry: Array[Dictionary]
	
	for action in InputMap.get_actions():
		if action in last_action_names:
			continue
			
		if Input.is_action_pressed(action):
			cur_entry.append({"action": action, "duration": 1})
			found_input = true
	
	if not found_input and not inputs_held:
		if last_actions != null and "neutral" not in last_action_names:
			command_history.append([{"action": "neutral", "duration": 1}])
		elif last_actions != null and "neutral" in last_action_names:
			for action in last_actions:
				if action["action"] == "neutral":
					action["duration"] += 1
	elif found_input and not inputs_held:
		command_history.append(cur_entry)
	elif found_input and inputs_held:
		var last_actions_copy: Array = last_actions.duplicate(true)
		last_actions_copy.append_array(cur_entry)
		command_history.append(last_actions_copy)

	
	var total_duration: int = 0
	for i in range(0, command_history.size()):
		for j in range(0, command_history[i].size()):
			total_duration += command_history[i][j]["duration"]
		
	while total_duration > COMMAND_HISTORY_DURATION:
		var popped_entry = command_history.pop_front()
		for entry in popped_entry:
			total_duration -= entry["duration"]
	
func checkCommandInput(command: Array[String], leniency: int, facing_position_matters: bool = true) -> bool:
	var inputs_found: Array[String]
	var input_to_find: int = 0
	var prev_command: String = ""
	var actual_command: Array[String] = command.duplicate(true)
		
	if facing_position_matters and Global.player != null:
		for i in range(0, actual_command.size()):
			if actual_command[i] == "move_right" and Global.player.facing_position == -1:
				actual_command[i] = "move_left"
			elif actual_command[i] == "move_left" and Global.player.facing_position == -1:
				actual_command[i] = "move_right"
	
	for buttons in command_history:
		for button in buttons:
				
			if button["action"].begins_with("ui") or (button["action"] == "neutral" and input_to_find == 0):
				continue
			if actual_command[input_to_find] == button["action"] and button["duration"] <= leniency and button["action"] != prev_command:
				inputs_found.append(actual_command[input_to_find])
				input_to_find += 1
				prev_command = button["action"]
			elif (actual_command[input_to_find] == button["action"] or button["action"] == "neutral") and button["duration"] > leniency:
				inputs_found.append(actual_command[input_to_find] + "_hold")
				prev_command = button["action"] + "_hold"
				input_to_find += 1
			elif button["action"] == "neutral" and button["duration"] <= leniency:
				prev_command = ""
			elif button["action"] != "neutral" and button["action"] != prev_command:
				return false
			if input_to_find == command.size():
				break
		if input_to_find == command.size():
			break
	
	if command.size() > inputs_found.size():
		return false
		
	for i in range(0, command.size()):
		if inputs_found[i] != actual_command[i]:
			return false
			
	command_history.clear()
	return true


# Called whenever the player makes an input.
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if !event.pressed or event.is_echo():
			return

		var scancode: int = event.keycode
		keyboard_timestamps[scancode] = Time.get_ticks_msec()
		var physical_scancode: int = event.physical_keycode
		keyboard_timestamps[physical_scancode] = Time.get_ticks_msec()
	elif event is InputEventJoypadButton:
		if !event.pressed or event.is_echo():
			return
			
		var button_index: int = event.button_index
		joypad_timestamps[button_index] = Time.get_ticks_msec()
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) < JOY_DEADZONE:
			return

		var axis_code: String = str(event.axis) + "_" + str(sign(event.axis_value))
		joypad_timestamps[axis_code] = Time.get_ticks_msec()

# Returns whether any of the keyboard keys or joypad buttons in the given action were pressed within the buffer window.
func is_action_press_buffered(action: String) -> bool:
	if BUFFER_WINDOW == 0 or Global.game.touch_screen_enabled:
		return Input.is_action_just_pressed(action)
	# Get the inputs associated with the action. If any one of them was pressed in the last BUFFER_WINDOW milliseconds,
	# the action is buffered.
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var scancode: int = event.keycode
			var physical_scancode: int = event.physical_keycode
			if keyboard_timestamps.has(scancode):
				if Time.get_ticks_msec() - keyboard_timestamps[scancode] <= BUFFER_WINDOW:
					# Prevent this method from returning true repeatedly and registering duplicate actions.
					_invalidate_action(action)
					return true;
			if keyboard_timestamps.has(physical_scancode):
				if Time.get_ticks_msec() - keyboard_timestamps[physical_scancode] <= BUFFER_WINDOW:
					# Prevent this method from returning true repeatedly and registering duplicate actions.
					_invalidate_action(action)
					return true;
		elif event is InputEventJoypadButton:
			var button_index: int = event.button_index
			if joypad_timestamps.has(button_index):
				var delta = Time.get_ticks_msec() - joypad_timestamps[button_index]
				if delta <= BUFFER_WINDOW:
					_invalidate_action(action)
					return true
		elif event is InputEventJoypadMotion:
			if abs(event.axis_value) < JOY_DEADZONE:
				return false
			var axis_code: String = str(event.axis) + "_" + str(sign(event.axis_value))
			if joypad_timestamps.has(axis_code):
				var delta = Time.get_ticks_msec() - joypad_timestamps[axis_code]
				if delta <= BUFFER_WINDOW:
					_invalidate_action(action)
					return true
	# If there's ever a third type of buffer-able action (mouse clicks maybe?), it'd probably be worth it to generalize
	# the repetitive keyboard/joypad code into something that works for any input method. Until then, by the YAGNI
	# principle, the repetitive stuff stays >:)
	
	return false


# Records unreasonable timestamps for all the inputs in an action. Called when IsActionPressBuffered returns true, as
# otherwise it would continue returning true every frame for the rest of the buffer window.
func _invalidate_action(action: String) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var scancode: int = event.keycode
			if keyboard_timestamps.has(scancode):
				keyboard_timestamps[scancode] = 0
			var physical_scancode: int = event.physical_keycode
			if keyboard_timestamps.has(physical_scancode):
				keyboard_timestamps[physical_scancode] = 0
		elif event is InputEventJoypadButton:
			var button_index: int = event.button_index
			if joypad_timestamps.has(button_index):
				joypad_timestamps[button_index] = 0
		elif event is InputEventJoypadMotion:
			var axis_code: String = str(event.axis) + "_" + str(sign(event.axis_value))
			if joypad_timestamps.has(axis_code):
				joypad_timestamps[axis_code] = 0
