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
const TRAINING_ROOM_EXTRA_OFFSET: Vector2 = Vector2(430, 0)
var glow_button_tween: Tween
var cur_button: Button
var cur_challenge_level: TrainingMode.TrainingLevel = TrainingMode.TrainingLevel.BEGINNER
var cur_challenge_level_playable: bool = true
const TWEEN_DURATION: float = 0.4
var player_global_position: Vector2
var player_current_room: String
static var cur_training: TrainingMode.Training = TrainingMode.Training.NONE

func _ready() -> void:
	Global.training_menu = self
	for button: Button in buttons.get_children():
		button.pressed.connect(pressButton.bind(button))
		button.focus_entered.connect(focusButton.bind(button))
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug") and Global.screen == Global.ScreenType.NONE:
		openMenu()
	elif Input.is_action_just_pressed("debug") and Global.screen == Global.ScreenType.TRAINING_MENU:
		closeMenu()
		
	if Global.screen == Global.ScreenType.TRAINING_MENU and not animation.is_playing():
		if Input.is_action_just_pressed("guard"):
			changeChallengeLevel(1)
		elif Input.is_action_just_pressed("backdash"):
			changeChallengeLevel(-1)

func openMenu():
	get_tree().paused = true
	Global.screen = Global.ScreenType.TRAINING_MENU
	animation.play("open")
	await animation.animation_finished
	if cur_button:
		cur_button.grab_focus()
	else:
		default_button.grab_focus()
	
func closeMenu():
	if glow_button_tween and glow_button_tween.is_running():
		glow_button_tween.kill()
		cur_button.self_modulate = Color.WHITE
	get_viewport().gui_release_focus()
	animation.play_backwards("open")
	await animation.animation_finished
	visible = false
	get_tree().paused = false
	Global.screen = Global.ScreenType.NONE
	
func startTraining():
	var training: TrainingMode = trainings[cur_button.get_index()]
	var enemies_number: int
	TrainingSettings.player_global_position = Global.player.global_position
	TrainingSettings.player_current_room = MetSys.get_full_room_path(MetSys.get_current_room_name())
	animation.play_backwards("open")
	await Global.total_fade_screen.fadeOutFor(0.5)
	match cur_challenge_level:
		TrainingMode.TrainingLevel.BEGINNER:
			enemies_number = training.enemies_beginner.size()
		TrainingMode.TrainingLevel.INTERMEDIATE:
			enemies_number = training.enemies_intermediate.size()
		TrainingMode.TrainingLevel.ADVANCED:
			enemies_number = training.enemies_advanced.size()
	Global.change_area.emit(TRAINING_ROOM_PATH, TRAINING_ROOM_INITIAL_POSITION + TRAINING_ROOM_EXTRA_OFFSET*int(enemies_number > 1))
	TrainingSettings.HP_depletion_in = training.HP_depletion_in
	TrainingSettings.damage_upon_hit = training.damage_upon_hit
	TrainingSettings.hearts_to_collect = training.hearts_to_collect + training.hearts_to_collect * (training.heart_level_multiplier-1) * cur_challenge_level
	TrainingSettings.collected_hearts = 0
	TrainingSettings.remove_hearts = training.remove_hearts
	TrainingSettings.remove_MP = training.remove_MP
	TrainingSettings.cur_challenge = TrainingMode.Training.values()[cur_button.get_index()+1]
	match cur_challenge_level:
		TrainingMode.TrainingLevel.BEGINNER:
			TrainingSettings.enemies = training.enemies_beginner
		TrainingMode.TrainingLevel.INTERMEDIATE:
			TrainingSettings.enemies = training.enemies_intermediate
		TrainingMode.TrainingLevel.ADVANCED:
			TrainingSettings.enemies = training.enemies_advanced
	await get_tree().create_timer(2, true).timeout
	Global.screen = Global.ScreenType.TRAINING
	get_tree().paused = false
	visible = false
	await Global.total_fade_screen.fadeInFor(0.5)

func focusButton(button: Button):
	sound.play_sound_effect_from_library("cursor")
	var new_training: TrainingMode = trainings[button.get_index()]

	if glow_button_tween and glow_button_tween.is_running():
		glow_button_tween.kill()
		cur_button.self_modulate = Color.WHITE
	if button != cur_button:
		cur_challenge_level = TrainingMode.TrainingLevel.BEGINNER
		challenge_description_label.text = new_training.challenge_beginner
		challenge_level_label.text = "Beginner"
		challenge_level_label.self_modulate = Color.WHITE

	cur_button = button
	glow_button_tween = get_tree().create_tween()
	glow_button_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	glow_button_tween.tween_property(cur_button, "self_modulate", Color.WHITE, TWEEN_DURATION).from(Color.DIM_GRAY)
	glow_button_tween.tween_property(cur_button, "self_modulate", Color.DIM_GRAY, TWEEN_DURATION)
	glow_button_tween.set_loops()
	training_title.text = new_training.title
	training_description.new_text = new_training.description
	training_icon.texture = new_training.icon
	
func pressButton(button: Button) -> void:
	if not cur_challenge_level_playable:
		sound.play_sound_effect_from_library("denied")
		return
		
	sound.play_sound_effect_from_library("confirm")
	cur_training = TrainingMode.Training.values()[button.get_index()]
	get_viewport().gui_release_focus()
	startTraining()

func changeChallengeLevel(offset: int) -> void:
	cur_challenge_level = posmod(cur_challenge_level+offset, TrainingMode.TrainingLevel.size()-1)
	var cur_challenge = trainings[cur_button.get_index()]
	var cur_challenge_descriptions: Array[String] = [cur_challenge.challenge_beginner, cur_challenge.challenge_intermediate, cur_challenge.challenge_advanced]
	challenge_level_label.text = CHALLENGE_LV_LABELS[cur_challenge_level]

	sound.play_sound_effect_from_library("cursor")
	
	cur_challenge_level_playable = cur_challenge.max_challenge_level >= cur_challenge_level
	if cur_challenge_level_playable:
		challenge_level_label.self_modulate = Color.WHITE
		challenge_description_label.text = cur_challenge_descriptions[cur_challenge_level]
	else:
		challenge_level_label.self_modulate = Color.DIM_GRAY
		challenge_description_label.text = "???"

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
