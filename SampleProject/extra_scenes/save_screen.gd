extends LoadingScreen
class_name SavingScreen
@warning_ignore("unused_signal")
signal finished #Used in save_disappear animation
var saved_with_success: bool = false
@export var confirm_panel_animation: AnimationPlayer
@export var confirm_panel: VBoxContainer
var confirm_panel_opened: bool = false
var closing: bool = false

enum ButtonIndex {
	YES,
	NO
}

func _process(delta: float) -> void:
	if confirm_panel_opened:
		if Input.is_action_just_pressed("ui_cancel"):
			_on_no_pressed()
		return
			
	if animation.is_playing() or confirm_panel_animation.is_playing():
		return 
		
	checkInput()

func onSlotPressed():
	sound.play_sound_effect_from_library("confirm")
	if containsData(focused_slot):
		askConfirm()
	else:
		saveData()
		exitScreen()

func exitScreen():
	if closing:
		return
	closing = true
	animation.play_backwards("save_disappear")

func saveData():
	Global.player.stats.map_ratio = "%3d%%" % int(MetSys.get_explored_ratio() * 100)
	var destination = INITIAL_SAVE_PATH + str(focused_slot) + SAVE_FILE_EXTENSION
	Global.save_destination = destination
	Game.get_singleton().save_game()
	Game.get_singleton().reset_map_starting_coords()
	saved_with_success = true

func askConfirm():
	confirm_panel_opened = true
	confirm_panel_animation.play("ask_confirm")
	confirm_panel.get_child(ButtonIndex.NO).grab_focus()
	sound.play_sound_effect_from_library("popup")

func _on_yes_pressed() -> void:
	sound.play_sound_effect_from_library("confirm")
	confirm_panel.get_child(ButtonIndex.YES).release_focus()
	saveData()
	confirm_panel_opened = false
	confirm_panel_animation.play_backwards("ask_confirm")
	await confirm_panel_animation.animation_finished
	closing = true
	animation.play_backwards("save_disappear")
	
func _on_no_pressed() -> void:
	confirm_panel.get_child(ButtonIndex.YES).release_focus()
	confirm_panel.get_child(ButtonIndex.NO).release_focus()
	confirm_panel_animation.play_backwards("ask_confirm")
	await confirm_panel_animation.animation_finished
	confirm_panel_opened = false

func _on_focused() -> void:
	sound.play_sound_effect_from_library("cursor")
