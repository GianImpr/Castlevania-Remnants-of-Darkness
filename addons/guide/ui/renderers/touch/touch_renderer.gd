@tool
extends GUIDEIconRenderer

const GUIDEInputTouchBase = preload("../../../inputs/guide_input_touch_base.gd")

@onready var _controls:Control = %Controls
@onready var _1_finger:Control = %T1Finger
@onready var _2_finger:Control = %T2Fingers
@onready var _3_finger:Control = %T3Fingers
@onready var _4_finger:Control = %T4Fingers
@onready var _rotate:Control = %Rotate
@onready var _zoom:Control = %Zoom


@onready var _directions:Control = %Directions
@onready var _horizontal:Control = %Horizontal
@onready var _vertical:Control = %Vertical
@onready var _axis2d:Control = %Axis2D



func supports(input:GUIDEInput) -> bool:
	return input is GUIDEInputTouchAxis1D or \
		input is GUIDEInputTouchAxis2D or \
		input is GUIDEInputTouchPosition or \
		input is GUIDEInputTouchAngle or \
		input is GUIDEInputTouchDistance
		
	
	
func render(input:GUIDEInput) -> void:
	for child in _controls.get_children():
		child.visible = false
	for child in _directions.get_children():
		child.visible = false
		
	_directions.visible = false
		
	if input is GUIDEInputTouchBase:
		match input.finger_count:
			2:
				_2_finger.visible = true
			3:
				_3_finger.visible = true
			4:
				_4_finger.visible = true
			_:
				# we have no icons for more than 4 fingers, so everything else gets
				# the 1 finger icon
				_1_finger.visible = true	
		
	if input is GUIDEInputTouchAxis2D:
		_directions.visible = true
		_axis2d.visible = true
		
	if input is GUIDEInputTouchAxis1D:
		_directions.visible = true
		match input.axis:
			GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.X:
				_horizontal.visible = true
			GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.X:
				_vertical.visible = true
				
	if input is GUIDEInputTouchDistance:
		_zoom.visible = true
		
	if input is GUIDEInputTouchAngle:
		_rotate.visible = true
		
	call("queue_sort")
 
func cache_key(input:GUIDEInput) -> String:
	return "1f4c5082-d419-465f-aba8-f889caaff335" + input.to_string()
