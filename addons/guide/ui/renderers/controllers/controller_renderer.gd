@tool
extends GUIDEIconRenderer

@export var controller_name_matches:Array[String] = []
@export var a_button:Texture2D
@export var b_button:Texture2D
@export var x_button:Texture2D
@export var y_button:Texture2D
@export var left_stick:Texture2D
@export var left_stick_click:Texture2D
@export var right_stick:Texture2D
@export var right_stick_click:Texture2D
@export var left_bumper:Texture2D
@export var right_bumper:Texture2D
@export var left_trigger:Texture2D
@export var right_trigger:Texture2D
@export var dpad_up:Texture2D
@export var dpad_left:Texture2D
@export var dpad_right:Texture2D
@export var dpad_down:Texture2D
@export var start:Texture2D
@export var misc1:Texture2D
@export var back:Texture2D


@onready var _a_button:TextureRect = %AButton
@onready var _b_button:TextureRect = %BButton
@onready var _x_button:TextureRect = %XButton
@onready var _y_button:TextureRect = %YButton
@onready var _left_stick:TextureRect = %LeftStick
@onready var _left_stick_click:TextureRect = %LeftStickClick
@onready var _right_stick:TextureRect = %RightStick
@onready var _right_stick_click:TextureRect = %RightStickClick
@onready var _left_bumper:Control = %LeftBumper
@onready var _right_bumper:Control = %RightBumper
@onready var _left_trigger:Control = %LeftTrigger
@onready var _right_trigger:TextureRect = %RightTrigger
@onready var _dpad_up:TextureRect = %DpadUp
@onready var _dpad_left:TextureRect = %DpadLeft
@onready var _dpad_right:TextureRect = %DpadRight
@onready var _dpad_down:TextureRect = %DpadDown
@onready var _start:TextureRect = %Start
@onready var _misc1:TextureRect = %Misc1
@onready var _back:TextureRect = %Back
@onready var _left_right:Control = %LeftRight
@onready var _up_down:Control = %UpDown
@onready var _controls:Control = %Controls
@onready var _directions:Control = %Directions


func _ready():
	super()
	_a_button.texture = a_button 
	_b_button.texture = b_button 
	_x_button.texture = x_button 
	_y_button.texture = y_button 
	_left_stick.texture = left_stick 
	_left_stick_click.texture = left_stick_click 
	_right_stick.texture = right_stick 
	_right_stick_click.texture = right_stick_click 
	_left_bumper.texture = left_bumper 
	_right_bumper.texture = right_bumper 
	_left_trigger.texture = left_trigger 
	_right_trigger.texture = right_trigger 
	_dpad_up.texture = dpad_up 
	_dpad_left.texture = dpad_left 
	_dpad_right.texture = dpad_right 
	_dpad_down.texture = dpad_down 
	_start.texture = start 
	_misc1.texture = misc1 
	_back.texture = back 

func supports(input:GUIDEInput) -> bool:
	var joy_name = GUIDEInputFormatter._joy_name_for_input(input)
	if joy_name == "":
		return false
	
	# Look if the controller name matches one of the supported ones	
	var haystack = joy_name.to_lower()
	for needle in controller_name_matches:
		if haystack.contains(needle.to_lower()):
			return true 	
	
	return false
	
func render(input:GUIDEInput) -> void:
	for control in _controls.get_children():
		control.visible = false
	for direction in _directions.get_children():
		direction.visible = false
	_directions.visible = false
		
	
	if input is GUIDEInputJoyAxis1D:
		match input.axis:
			JOY_AXIS_LEFT_X:
				_left_stick.visible = true
				_show_left_right()
			JOY_AXIS_LEFT_Y:
				_left_stick.visible = true
				_show_up_down()
			JOY_AXIS_RIGHT_X:
				_right_stick.visible = true
				_show_left_right()
			JOY_AXIS_RIGHT_Y:
				_right_stick.visible = true
				_show_up_down()
			JOY_AXIS_TRIGGER_LEFT:
				_left_trigger.visible = true
			JOY_AXIS_TRIGGER_RIGHT:
				_right_trigger.visible = true
	
	if input is GUIDEInputJoyAxis2D:
		# We assume that there is no input mixing horizontal and vertical
		# from different sticks into a 2D axis as this would confuse the 
		# players. 
		match input.x:
			JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
				_left_stick.visible = true
			JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
				_right_stick.visible = true
				
	if input is GUIDEInputJoyButton:
		match input.button:
			JOY_BUTTON_A:
				_a_button.visible = true
			JOY_BUTTON_B:
				_b_button.visible = true
			JOY_BUTTON_X:
				_x_button.visible = true
			JOY_BUTTON_Y:
				_y_button.visible = true
			JOY_BUTTON_DPAD_LEFT:
				_dpad_left.visible = true
			JOY_BUTTON_DPAD_RIGHT:
				_dpad_right.visible = true
			JOY_BUTTON_DPAD_UP:
				_dpad_up.visible = true
			JOY_BUTTON_DPAD_DOWN:
				_dpad_down.visible = true
			JOY_BUTTON_LEFT_SHOULDER:
				_left_bumper.visible = true
			JOY_BUTTON_RIGHT_SHOULDER:
				_right_bumper.visible = true
			JOY_BUTTON_LEFT_STICK:
				_left_stick_click.visible = true
			JOY_BUTTON_RIGHT_STICK:
				_right_stick_click.visible = true
			JOY_BUTTON_RIGHT_STICK:
				_right_stick_click.visible = true
			JOY_BUTTON_START:
				_start.visible = true
			JOY_BUTTON_BACK:
				_back.visible = true
			JOY_BUTTON_MISC1:
				_misc1.visible = true
					
	call("queue_sort")		
				 								

func _show_left_right():
	_directions.visible = true
	_left_right.visible = true

func _show_up_down():
	_directions.visible = true
	_up_down.visible = true
	
 
func cache_key(input:GUIDEInput) -> String:
	return "7581f483-bc68-411f-98ad-dc246fd2593a" + input.to_string() + GUIDEInputFormatter._joy_name_for_input(input)
