extends Node2D
const PRESSED_COLOR: Color = Color(1,0,1,1)
const DEFAULT_COLOR: Color = Color(1,1,1,1)

func _ready() -> void:
	for i in range(0, get_child_count()):
		if i != get_child_count()-1:
			get_child(i).connect("pressed", press.bind(i))
			get_child(i).connect("released", release.bind(i))
		else:
			get_child(i).connect("pressed", toggle_touch)

func press(button_index: int) -> void:
	get_child(button_index).modulate = PRESSED_COLOR
	
func release(button_index: int) -> void:
	get_child(button_index).modulate = DEFAULT_COLOR
	
func toggle_touch() -> void:
	Global.game.touch_screen_enabled = not Global.game.touch_screen_enabled
	for i in range(0, get_child_count()-1):
		get_child(i).visible = Global.game.touch_screen_enabled
