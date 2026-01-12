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
const TRAINING_ROOM_PATH: String = "res://SampleProject/Maps/TrainingRoom/training_room.tscn"
const TRAINING_ROOM_INITIAL_POSITION: Vector2 = Vector2(100, 364)
var glow_button_tween: Tween
var cur_button: Button
var cur_challenge_level: TrainingMode.TrainingLevel
var cur_challenge_level_playable: bool = true
const TWEEN_DURATION: float = 0.5
var player_global_position: Vector2
var player_current_room: String
static var cur_training: TrainingMode.Training = TrainingMode.Training.NONE

func _ready() -> void:
	for button: Button in buttons.get_children():
		button.pressed.connect(pressButton.bind(button))
		button.focused.connect(focusButton.bind(button))

func openMenu():
	get_tree().paused = true
	Global.screen = Global.ScreenType.TRAINING_MENU
	animation.play("open")
	await animation.animation_finished
	default_button.grab_focus()
	cur_challenge_level = TrainingMode.TrainingLevel.BEGINNER
	cur_challenge_level_playable = true
	
func closeMenu():
	cur_button.release_focus()
	animation.play_backwards("open")
	await animation.animation_finished
	get_tree().paused = false
	Global.screen = Global.ScreenType.NONE
	
func startTraining():
	cur_button.release_focus()
	player_global_position = Global.player.global_position
	player_current_room = MetSys.get_full_room_path(MetSys.get_current_room_name())
	animation.play_backwards("open")
	await animation.animation_finished
	Global.change_area.emit(TRAINING_ROOM_PATH, TRAINING_ROOM_INITIAL_POSITION)

func focusButton(button: Button):
	sound.play_sound_effect_from_library("cursor")
	if glow_button_tween.is_valid() and glow_button_tween.is_running():
		glow_button_tween.kill()
		cur_button.self_modulate = Color.WHITE
	cur_button = button
	glow_button_tween = get_tree().create_tween()
	glow_button_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	glow_button_tween.tween_property(cur_button, "self_modulate", Color.DARK_GRAY, TWEEN_DURATION)
	glow_button_tween.tween_property(cur_button, "self_modulate", Color.WHITE, TWEEN_DURATION)
	cur_challenge_level = TrainingMode.TrainingLevel.BEGINNER
	
func pressButton(button: Button) -> void:
	if not cur_challenge_level_playable:
		sound.play_sound_effect_from_library("denied")
		return
		
	sound.play_sound_effect_from_library("confirm")
	cur_training = TrainingMode.Training.values()[button.get_index()]
	get_viewport().gui_release_focus()
	animation.play("start")

func changeChallengeLevel(offset: int) -> void:
	cur_challenge_level = posmod(cur_challenge_level+offset, TrainingMode.TrainingLevel.size()-1)
	challenge_level_label.text = CHALLENGE_LV_LABELS[cur_challenge_level]
	var cur_challenge = trainings[cur_button.get_index()]
	
	cur_challenge_level_playable = cur_challenge.max_playable_level > cur_challenge_level
	if cur_challenge_level_playable:
		challenge_level_label.self_modulate = Color.WHITE
	else:
		challenge_level_label.self_modulate = Color.DIM_GRAY

func serializeTrainingLevels() -> Array[TrainingMode.TrainingLevel]:
	var training_levels: Array[TrainingMode.TrainingLevel]
	for training in trainings:
		training_levels.append(training.max_challenge_level)
	return training_levels

func deserializeTrainingLevels(levels: Array[TrainingMode.TrainingLevel]) -> void:
	assert(levels.size() != null && levels.size() != 0, "Failed to deserialize all levels: missing data on levels unlocked")
	assert(levels.size() == trainings.size(), "Failed to deserialize all levels: size mismatch.")
		
	for i in range(0, trainings.size()):
		trainings[i].max_challenge_level = levels[i]
