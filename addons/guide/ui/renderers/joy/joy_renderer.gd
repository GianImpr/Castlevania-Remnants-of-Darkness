@tool
extends GUIDEIconRenderer

@onready var _stick:Control = %Stick
@onready var _button:Control = %Button
@onready var _text:Control = %Text
@onready var _directions:Control = %Directions
@onready var _horizontal:Control = %Horizontal
@onready var _vertical:Control = %Vertical



func supports(input:GUIDEInput) -> bool:
	return input is GUIDEInputJoyBase
	
func render(input:GUIDEInput) -> void:
	_stick.visible = false
	_button.visible = false
	_directions.visible = false
	_horizontal.visible = false
	_vertical.visible = false	
	_text.text = ""

		
	if input is GUIDEInputJoyAxis1D:
		_stick.visible = true
		match input.axis:
			JOY_AXIS_LEFT_X:
				_directions.visible = true
				_text.text = "1"
				_horizontal.visible = true
			JOY_AXIS_RIGHT_X:
				_directions.visible = true
				_text.text = "2"
				_horizontal.visible = true
			JOY_AXIS_LEFT_Y:
				_directions.visible = true
				_text.text = "1"
				_vertical.visible = true
			JOY_AXIS_RIGHT_Y:
				_directions.visible = true
				_text.text = "2"
				_vertical.visible = true
			JOY_AXIS_TRIGGER_LEFT:
				_text.text = "3"
			JOY_AXIS_TRIGGER_RIGHT:
				_text.text = "4"
								
	
	
	if input is GUIDEInputJoyAxis2D:
		_stick.visible = true
		match input.x:
			JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
				_text.text = "1"
			JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
				_text.text = "2"
			_:
				# well we don't know really what this is but what can we do.
				_text.text = str(input.x + input.y)
		
	if input is GUIDEInputJoyButton:
		_button.visible = true
		_text.text = str(input.button)
			
	call("queue_sort")
 
func cache_key(input:GUIDEInput) -> String:
	return "a9ced629-de65-4c31-9de0-8e4cbf88a2e0" + input.to_string()
