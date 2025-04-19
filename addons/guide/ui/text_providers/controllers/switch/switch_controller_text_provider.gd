extends "res://addons/guide/ui/text_providers/controllers/controller_text_provider.gd"

func _controller_names() -> Array[String]:
	return ["Nintendo Switch"]	
	
func _a_button_name() -> String:
	return "B"

func _b_button_name() -> String:
	return "A"

func _x_button_name() -> String:
	return "Y"

func _y_button_name() -> String:
	return "X"

func _left_bumper_name() -> String:
	return "L"

func _right_bumper_name() -> String:
	return "R"

func _left_trigger_name() -> String:
	return "ZL"

func _right_trigger_name() -> String:
	return "ZR"

func _back_button_name() -> String:
	return "-"

func _misc_1_button_name() -> String:
	return "Square"

func _start_button_name() -> String:
	return "+"
