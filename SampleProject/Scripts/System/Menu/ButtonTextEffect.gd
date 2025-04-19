@tool
extends RichTextLabel
class_name RichTextLabelWithButtons
var controller_scheme: int = 0:
	set(value):
		controller_scheme = value
		setButtons(value)
@export_multiline var new_text: String:
	set(value):
		var parsed_text = parseText(value)
		new_text = value
		text = parsed_text
const path: String = "res://assets/sprites/HUD/Buttons/"
var buttons: Dictionary

const Buttons = {
	SQUARE = "Square",
	CIRCLE = "Circle",
	CROSS = "Cross",
	TRIANGLE = "Triangle",
	START = "Options",
	SELECT = "Select",
	L1 = "L1",
	L2 = "L2",
	L3 = "L3",
	R1 = "R1",
	R2 = "R2",
	R3 = "R3",
	A = "A",
	B = "B",
	X = "X",
	Y = "Y",
	LB = "LB",
	LT = "LT",
	RB = "RB",
	RT = "RT",
	L = "L",
	R = "R",
	LSTICK = "LeftStick",
	RSTICK = "RightStick",
	ZL = "ZL",
	ZR = "ZR",
	PLUS = "Plus",
	MINUS = "Minus",
	UP = "Up",
	DOWN = "Down"
}

func setButtons(scheme: int) -> void:
	if Engine.is_editor_hint() or Global.settings_node == null:
		match scheme:
			0:
				buttons = {"Square": Buttons.SQUARE, "Circle": Buttons.CIRCLE, "Triangle": Buttons.TRIANGLE,
				"Cross": Buttons.CROSS, "L1": Buttons.L1, "L2": Buttons.L2, "L3": Buttons.L3, "R1": Buttons.R1,
				"R2": Buttons.R2, "R3": Buttons.R3, "Start": Buttons.START, "Select": Buttons.SELECT}
			1:
				buttons = {"Square": Buttons.X, "Circle": Buttons.B, "Triangle": Buttons.Y,
				"Cross": Buttons.A, "L1": Buttons.LB, "L2": Buttons.LT, "L3": Buttons.LSTICK, "R1": Buttons.RB,
				"R2": Buttons.RT, "R3": Buttons.RSTICK, "Start": Buttons.START, "Select": Buttons.SELECT}	
			2:
				buttons = {"Square": Buttons.Y, "Circle": Buttons.A, "Triangle": Buttons.X,
				"Cross": Buttons.B, "L1": Buttons.L, "L2": Buttons.ZL, "L3": Buttons.LSTICK, "R1": Buttons.R,
				"R2": Buttons.ZR, "R3": Buttons.RSTICK, "Start": Buttons.PLUS, "Select": Buttons.MINUS}
			_:
				buttons = {"Square": "J", "Circle": "L", "Triangle": "I",
				"Cross": "K", "L1": "U", "L2": "Y", "L3": Buttons.LSTICK, "R1": "O",
				"R2": Buttons.ZR, "R3": Buttons.RSTICK, "Start": "Enter", "Select": "M"}
				
		buttons.get_or_add("Up", Buttons.UP)
		buttons.get_or_add("Down", Buttons.DOWN)
	else:
		buttons = Global.settings_node.button_icons
		
func parseText(value: String) -> String:
	if Global.game != null:
		controller_scheme = Global.game.controller_scheme
	setButtons(controller_scheme)
	var result: String = ""
	var cur_pos: int = 0
	var par_position: int = value.find("[[")
	var close_position: int = 0
	while par_position > 0:
		close_position = value.substr(cur_pos, -1).find("]]")
		if par_position > close_position:
			break
		var button: String = value.substr(cur_pos+par_position+2, close_position-par_position-2)
		result = result + value.substr(cur_pos, par_position)
		if controller_scheme != Global.game.ControllerScheme.KEYBOARD:
			result = result + "[img]" + path + buttons[button] + ".png[/img]"
		else:
			result = result + buttons[button]
		cur_pos = cur_pos + close_position + 2
		par_position = value.substr(cur_pos, -1).find("[[")
	result = result + value.substr(cur_pos, -1)
	return result
