extends Control
@export var animation: AnimationPlayer
@export var loading_screen: PackedScene
@export var save_label: Label
@export var buttons: VBoxContainer
@export var sound: PolyphonicMenuAudio

const TWEEN_DURATION: float = 1
const BUTTON_QUANTITY: int = 4
var cur_button: int = 0
var tween: Tween

func _ready() -> void:
	highlightFocusedButton(0)

func _process(delta: float) -> void:
	if not animation.is_playing():
		if Input.is_action_just_pressed("ui_accept"):
			animation.play("disappear")
		elif Input.is_action_just_pressed("ui_up"):
			var prev_button: int = cur_button
			cur_button = posmod(cur_button-1, BUTTON_QUANTITY)
			sound.play_sound_effect_from_library("cursor")
			highlightFocusedButton(prev_button)
		elif Input.is_action_just_pressed("ui_down"):
			var prev_button: int = cur_button
			cur_button = posmod(cur_button+1, BUTTON_QUANTITY)
			sound.play_sound_effect_from_library("cursor")
			highlightFocusedButton(prev_button)

func startLoadingScreen():
	if tween != null:
		tween.kill()
	get_tree().change_scene_to_packed(loading_screen)
	
func highlightFocusedButton(previous_button: int) -> void:
	if tween != null:
		tween.kill()
	buttons.get_child(previous_button).modulate = Color.WHITE
	tween = get_tree().create_tween()
	tween.tween_property(buttons.get_child(cur_button), "modulate", Color.DARK_RED, TWEEN_DURATION).from(Color.RED)
	tween.tween_property(buttons.get_child(cur_button), "modulate", Color.RED, TWEEN_DURATION).from(Color.DARK_RED)
	tween.finished.connect(highlightFocusedButton.bind(cur_button-1))
