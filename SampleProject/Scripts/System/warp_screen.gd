extends Control
class_name WarpScreen

const BUTTON_FOCUSED_COLOR: Color = Color(1, 0.733, 0)
const BUTTON_DISABLED_COLOR: Color = Color.DIM_GRAY

@export var sound: PolyphonicMenuAudio
@export var panel: VBoxContainer
@export var animation: AnimationPlayer
@export var preview: TextureRect #950x950
var available_destinations: Array[int]
var destination_selected: String = ""
var destination_flip: bool = false
var cur_button: int = 0
var stylebox_empty: StyleBoxEmpty = StyleBoxEmpty.new()
@warning_ignore("unused_signal")
signal finished #Emits at the end of disappear animation

func initList() -> void:
	var current_room: Room = MetSys.get_current_room_instance().get_parent()
	for i in range(0, Game.get_singleton().save_rooms.size()):
		if Global.player.stats.save_flags[i]:
			available_destinations.append(i)
			var destination_button: Button = Button.new()
			destination_button.flat = true
			destination_button.text = Game.get_singleton().save_rooms[i]["name"]
			destination_button.add_theme_stylebox_override("focus", stylebox_empty)
			destination_button.add_theme_stylebox_override("hover", stylebox_empty)
			destination_button.add_theme_stylebox_override("pressed", stylebox_empty)
			destination_button.pressed.connect(_on_button_pressed.bind(destination_button))
			destination_button.focus_entered.connect(_on_button_focused.bind(destination_button))
			destination_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			destination_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
			#This is the room we're currently in
			if current_room.save_room_id == i+1:
				destination_button.disabled = true
			
			destination_button.add_theme_color_override("font_disabled_color", BUTTON_DISABLED_COLOR)
			destination_button.add_theme_color_override("font_focus_color", BUTTON_FOCUSED_COLOR)
			panel.add_child(destination_button)
	panel.get_child(0).grab_focus()

func closeList() -> void:
	for child in panel.get_children():
		child.queue_free()
	available_destinations.clear()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and not animation.is_playing() and panel.get_child_count() > 0:
		panel.get_child(cur_button).release_focus()
		animation.play_backwards("disappear")

func _on_button_focused(which) -> void:
	preview.texture = Game.get_singleton().save_rooms[available_destinations[which.get_index()]]["image"]
	cur_button = which.get_index()
	sound.play_sound_effect_from_library("cursor")
	
func _on_button_pressed(which) -> void:
	destination_selected = Game.get_singleton().save_rooms[available_destinations[which.get_index()]]["path"]
	destination_flip = Game.get_singleton().save_rooms[available_destinations[which.get_index()]]["flip"]
	sound.play_sound_effect_from_library("confirm")
	animation.play_backwards("disappear")
