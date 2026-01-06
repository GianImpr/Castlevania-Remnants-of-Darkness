extends Control
class_name TrainingMenu

@export var trainings: Array[TrainingMode]
@export var animation: AnimationPlayer
@export var training_room: PackedScene
@export var default_button: Button
@export var buttons: VBoxContainer
@export var sound: PolyphonicMenuAudio
@export var training_icon: TextureRect
@export var training_description: RichTextLabelWithButtons
@export var training_title: Label
@export var challenge_level_label: RichTextLabelWithButtons
@export var challenge_description_label: RichTextLabelWithButtons
const CHALLENGE_LV_LABELS: Array[String] = ["Beginner", "Intermediate", "Advanced"]
var glow_button_tween: Tween
var cur_button: Button
var cur_challenge_level: TrainingMode.TrainingLevel
const TWEEN_DURATION: float = 0.5

func _ready() -> void:
	for button: Button in buttons.get_children():
		button.pressed.connect(sound.play_sound_effect_from_library.bind("confirm"))
		button.focused.connect(focusButton.bind(button))

func openMenu():
	animation.play("open")
	await animation.animation_finished
	default_button.grab_focus()
	
func closeMenu():
	cur_button.release_focus()
	animation.play("close")
	
func startTraining():
	return

func focusButton(button: Button):
	sound.play_sound_effect_from_library.bind("cursor")
	if glow_button_tween.is_valid() and glow_button_tween.is_running():
		glow_button_tween.kill()
		cur_button.self_modulate = Color.WHITE
	cur_button = button
	glow_button_tween = get_tree().create_tween()
	glow_button_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	glow_button_tween.tween_property(cur_button, "self_modulate", Color.DARK_GRAY, TWEEN_DURATION)
	glow_button_tween.tween_property(cur_button, "self_modulate", Color.WHITE, TWEEN_DURATION)
	cur_challenge_level = TrainingMode.TrainingLevel.BEGINNER

func changeChallengeLevel(offset: int) -> void:
	cur_challenge_level = posmod(cur_challenge_level+offset, TrainingMode.TrainingLevel.size())
	challenge_level_label = CHALLENGE_LV_LABELS[cur_challenge_level]
	if trainings[cur_button.get_index()].
