extends Node
class_name FocusSlider
var cur_button: Button = null
const SLIDING_SPEED: float = 0.075
const SLIDE_AFTER_SECONDS: float = 0.3
var hold_timer: Timer = Timer.new()
var holding: bool = false
var cur_action: String = ""
const ACTIONS: Array[String] = ["ui_up", "ui_down"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(hold_timer)
	hold_timer.one_shot = true
	hold_timer.wait_time = SLIDE_AFTER_SECONDS
	hold_timer.timeout.connect(startSliding)

func _input(event: InputEvent) -> void:
	cur_button = null
	updateCurButton()

		
	if cur_button == null:
		holding = false
		return
	
	for action in ACTIONS:
		if event.is_action_pressed(action) and hold_timer.is_stopped() and not holding:
			hold_timer.start()
			holding = true
			cur_action = action
			break
	
	if cur_action != "" and Input.is_action_just_released(cur_action) and (not hold_timer.is_stopped or holding):
		holding = false
		hold_timer.stop()
	
func startSliding() -> void:
	if holding:
		updateCurButton()
		if not cur_button:
			return

		var new_button: Button
		
		if cur_action == "ui_up":
			new_button = cur_button.find_valid_focus_neighbor(SIDE_TOP)
		else:
			new_button = cur_button.find_valid_focus_neighbor(SIDE_BOTTOM)
			
		if new_button:
			new_button.grab_focus()
		get_tree().create_timer(SLIDING_SPEED).timeout.connect(startSliding)

func updateCurButton() -> void:
	var focused_node = get_viewport().gui_get_focus_owner()
	if focused_node in get_parent().get_children():
		cur_button = focused_node
