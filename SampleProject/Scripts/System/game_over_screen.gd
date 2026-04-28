extends Control
class_name GameOverScreen
@export var animation: AnimationPlayer
@export var black_background: Control
@export var retry_battle_button: Button
@export var default_button: Button
@export var sound: PolyphonicMenuAudio
const MUSIC_DELAY_SECONDS: float = 0.5

func _ready() -> void:
	Global.game_over_screen = self

func showScreen() -> void:
	retry_battle_button.visible = SavingScreen.isBattleCheckpointSet()
	animation.play("start")
	await get_tree().create_timer(MUSIC_DELAY_SECONDS).timeout
	Global.music_player.play_sound_effect_from_library("game_over")
	Global.music_player.restoreVolumeDB()
	
func hideScreen() -> void:
	animation.play("hide")
	
func dismissBlackScreen(fade_in_duration: float = 1) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(black_background, "self_modulate", Color.TRANSPARENT, fade_in_duration)
	await tween.finished

func focusOnOptions() -> void:
	if retry_battle_button.visible:
		retry_battle_button.grab_focus()
	else:
		default_button.grab_focus()
	
func onFocused() -> void:
	sound.play_sound_effect_from_library("cursor")
	
func titleScreen() -> void:
	sound.play_sound_effect_from_library("confirm")
	get_viewport().gui_release_focus()
	hideScreen()
	await animation.animation_finished
	Global.toTitleScreen()
	
func retryBattle() -> void:
	sound.play_sound_effect_from_library("confirm")
	LoadingScreen.loadBattleCheckpoint()
	get_viewport().gui_release_focus()
	hideScreen()
	await animation.animation_finished
	get_tree().paused = false
	Global.loaded_settings = false
	get_tree().reload_current_scene()

	
func reloadSave() -> void:
	sound.play_sound_effect_from_library("confirm")
	SavingScreen.deleteBattleCheckpoint()
	if Global.save_destination != "":
		Global.save_file_to_load = Global.save_destination
	Global.load_data = Global.save_file_to_load != ""
	get_viewport().gui_release_focus()
	hideScreen()
	await animation.animation_finished
	get_tree().paused = false
	Global.loaded_settings = false
	get_tree().reload_current_scene()
