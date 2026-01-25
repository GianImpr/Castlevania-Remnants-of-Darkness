extends Control
class_name GameOverScreen
@export var animation: AnimationPlayer
@export var black_background: Control

func _ready() -> void:
	Global.game_over_screen = self

func showScreen() -> void:
	animation.play("start")
	await get_tree().create_timer(0.5).timeout
	Global.music_player.play_sound_effect_from_library("game_over")
	Global.music_player.restoreVolumeDB()
	
func hideScreen() -> void:
	animation.play("hide")
	
func dismissBlackScreen(fade_in_duration: float = 1) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(black_background, "self_modulate", Color.TRANSPARENT, fade_in_duration)
	await tween.finished
