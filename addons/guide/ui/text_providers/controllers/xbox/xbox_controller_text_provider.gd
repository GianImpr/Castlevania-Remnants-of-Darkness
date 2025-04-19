extends "res://addons/guide/ui/text_providers/controllers/controller_text_provider.gd"

func _controller_names() -> Array[String]:
	return ["XInput", "XBox"]	
	
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
	return "View"

func _misc_1_button_name() -> String:
	return "Share"

func _start_button_name() -> String:
	return "Menu"
