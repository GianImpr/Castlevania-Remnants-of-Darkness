extends GUIDETextProvider

func _init():
	priority = -1
	
func _controller_names() -> Array[String]:
	return []	
	
func _a_button_name() -> String:
	return "A"

func _b_button_name() -> String:
	return "B"

func _x_button_name() -> String:
	return "X"

func _y_button_name() -> String:
	return "Y"

func _left_bumper_name() -> String:
	return "LB"

func _right_bumper_name() -> String:
	return "RB"

func _left_trigger_name() -> String:
	return "LT"

func _right_trigger_name() -> String:
	return "RT"

func _back_button_name() -> String:
	return "Back"

func _misc_1_button_name() -> String:
	return "Misc 1"

func _start_button_name() -> String:
	return "Start"

	
func supports(input:GUIDEInput) -> bool:
	var controller_name = GUIDEInputFormatter._joy_name_for_input(input)
	if controller_name == "":
		return false
		
	var haystack = controller_name.to_lower()
	for needle in _controller_names():
		if haystack.contains(needle.to_lower()):
			return true
	
	return false

func _format(input:String) -> String:
	return "[%s]" % [input]

	
func get_text(input:GUIDEInput) -> String:
	if input is GUIDEInputJoyAxis1D:
		match input.axis:
			JOY_AXIS_LEFT_X:
				return _format(tr("Left Stick Horizontal"))
			JOY_AXIS_LEFT_Y:
				return _format(tr("Left Stick Vertical"))
			JOY_AXIS_RIGHT_X:
				return _format(tr("Right Stick Horizontal"))
			JOY_AXIS_RIGHT_Y:
				return _format(tr("Right Stick Vertical"))
			JOY_AXIS_TRIGGER_LEFT:
				return _format(tr(_left_trigger_name()))
			JOY_AXIS_TRIGGER_RIGHT:
				return _format(tr(_right_trigger_name()))
	
	if input is GUIDEInputJoyAxis2D:
		match input.x:
			JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
				return _format(tr("Left Stick"))
			JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
				return _format(tr("Right Stick"))
				
	if input is GUIDEInputJoyButton:
		match input.button:
			JOY_BUTTON_A:
				return _format(tr(_a_button_name()))
			JOY_BUTTON_B:
				return _format(tr(_b_button_name()))
			JOY_BUTTON_X:
				return _format(tr(_x_button_name()))
			JOY_BUTTON_Y:
				return _format(tr(_y_button_name()))
			JOY_BUTTON_DPAD_LEFT:
				return _format(tr("DPAD Left"))
			JOY_BUTTON_DPAD_RIGHT:
				return _format(tr("DPAD Right"))
			JOY_BUTTON_DPAD_UP:
				return _format(tr("DPAD Up"))
			JOY_BUTTON_DPAD_DOWN:
				return _format(tr("DPAD Down"))
			JOY_BUTTON_LEFT_SHOULDER:
				return _format(tr(_left_bumper_name()))	
			JOY_BUTTON_RIGHT_SHOULDER:
				return _format(tr(_right_bumper_name()))	
			JOY_BUTTON_LEFT_STICK:
				return _format(tr("Left Stick"))	
			JOY_BUTTON_RIGHT_STICK:
				return _format(tr("Right Stick"))	
			JOY_BUTTON_BACK:
				return _format(tr(_back_button_name()))
			JOY_BUTTON_MISC1:
				return _format(tr(_misc_1_button_name()))
			JOY_BUTTON_START:
				return _format(tr(_start_button_name()))		

	return _format("??")
