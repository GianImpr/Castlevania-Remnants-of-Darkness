extends Control
class_name WarpScreen

const BUTTON_FOCUSED_COLOR: Color = Color(1, 0.733, 0)
const BUTTON_DISABLED_COLOR: Color = Color.DIM_GRAY

@export var sound: PolyphonicMenuAudio
@export var panel: VBoxContainer
@export var animation: AnimationPlayer
var available_destinations: Array[int]
var destination_selected: String = ""
var cur_button: int = 0
@warning_ignore("unused_signal")
signal finished #Emits at the end of disappear animation

func initList() -> void:
	var current_room: Room = MetSys.get_current_room_instance().get_parent()
	for i in range(0, Global.player.stats.save_flags.size()):
		if Global.player.stats.save_flags[i]:
			available_destinations.append(i)
			var destination_button: Button = Button.new()
			destination_button.flat = true
			destination_button.text = Global.player.stats.save_rooms[i]["name"]
			
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
	if Input.is_action_just_pressed("ui_cancel") and not animation.is_playing():
		panel.get_child(cur_button).release_focus()
		animation.play_backwards("disappear")

func _on_button_focused(which) -> void:
	cur_button = which.get_index()
	sound.play_sound_effect_from_library("cursor")
	
func _on_button_pressed(which) -> void:
	destination_selected = Global.player.stats.save_rooms[available_destinations[which.get_index()]]["path"]
	sound.play_sound_effect_from_library("confirm")
	animation.play_backwards("disappear")
