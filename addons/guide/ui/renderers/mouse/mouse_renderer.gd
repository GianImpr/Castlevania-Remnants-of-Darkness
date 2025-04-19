@tool
extends GUIDEIconRenderer

@onready var _controls:Control = %Controls
@onready var _mouse_left:Control = %MouseLeft
@onready var _mouse_right:Control = %MouseRight
@onready var _mouse_middle:Control = %MouseMiddle
@onready var _mouse_side_a:Control = %MouseSideA
@onready var _mouse_side_b:Control = %MouseSideB
@onready var _mouse_blank:Control = %MouseBlank
@onready var _mouse_cursor:Control = %MouseCursor


@onready var _directions:Control = %Directions
@onready var _left:Control = %Left
@onready var _right:Control = %Right
@onready var _up:Control = %Up
@onready var _down:Control = %Down
@onready var _horizontal:Control = %Horizontal
@onready var _vertical:Control = %Vertical



func supports(input:GUIDEInput) -> bool:
	return input is GUIDEInputMouseButton or \
		input is GUIDEInputMouseAxis1D or \
		input is GUIDEInputMouseAxis2D or \
		input is GUIDEInputMousePosition
	
	
func render(input:GUIDEInput) -> void:
	for child in _controls.get_children():
		child.visible = false
	for child in _directions.get_children():
		child.visible = false
		
	_directions.visible = false
		
	if input is GUIDEInputMouseButton:
		match input.button:
			MOUSE_BUTTON_LEFT:
				_mouse_left.visible = true
			MOUSE_BUTTON_RIGHT:
				_mouse_right.visible = true
			MOUSE_BUTTON_MIDDLE:
				_mouse_middle.visible = true
			MOUSE_BUTTON_WHEEL_UP:
				_directions.visible = true
				_up.visible = true
				_mouse_middle.visible = true
			MOUSE_BUTTON_WHEEL_DOWN:
				_directions.visible = true
				_down.visible = true
				_mouse_middle.visible = true
			MOUSE_BUTTON_WHEEL_LEFT:
				_directions.visible = true
				_left.visible = true
				_mouse_middle.visible = true
			MOUSE_BUTTON_WHEEL_RIGHT:
				_directions.visible = true
				_right.visible = true
				_mouse_middle.visible = true
			MOUSE_BUTTON_XBUTTON1:
				_mouse_side_a.visible = true
			MOUSE_BUTTON_XBUTTON2:
				_mouse_side_b.visible = true
				
	if input is GUIDEInputMouseAxis1D:
		if input.axis == GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.X:
			_mouse_blank.visible = true
			_directions.visible = true
			_horizontal.visible = true
		else:
			_mouse_blank.visible = true
			_directions.visible = true
			_vertical.visible = true		
		
	if input is GUIDEInputMouseAxis2D:
		_mouse_blank.visible = true
		
	if input is GUIDEInputMousePosition:
		_mouse_cursor.visible = true
	
	call("queue_sort")
 
func cache_key(input:GUIDEInput) -> String:
	return "7e27520a-b6d8-4451-858d-e94330c82e85" + input.to_string()
