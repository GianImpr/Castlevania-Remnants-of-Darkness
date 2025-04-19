extends Control
class_name TutorialScreen
@export var animation: AnimationPlayer
@export var title: Label
@export var image: TextureRect
@export var description: RichTextLabelWithButtons
@export var continue_label: RichTextLabelWithButtons
@export var sound: PolyphonicMenuAudio

var current_tutorial_id: Tutorial
static var current_tutorial: TutorialFormat
@export var tutorials: Array[TutorialFormat]

enum Tutorial {
	GUARDING,
	GUARD_HEALTH,
	RELICS,
	RED_SPARK,
	PERFECT_GUARD,
	INNOCENT_DEVIL,
	HEART_METER,
	FAIRY_ID
}

func _process(delta: float) -> void:
	if Global.screen == Global.ScreenType.TUTORIAL and Input.is_action_just_pressed("jump") and not animation.is_playing():
		animation.play("disappear")
		sound.volume_db = -10
		sound.play_sound_effect_from_library("confirm")
		await animation.animation_finished
		disappear()

func _ready():
	Global.tutorial_screen = self
	TutorialScreenTrigger.setTutorial = setTutorial
	visible = false

func activate():
	visible = true
	sound.volume_db = -5
	Global.screen = Global.ScreenType.TUTORIAL
	sound.play_sound_effect_from_library("tutorial")
	get_tree().paused = true
	animation.play("appear")

func disappear():
	Global.screen = Global.ScreenType.NONE
	visible = false
	get_tree().paused = false

func setTutorial(tutorial_id: Tutorial) -> void:
	current_tutorial_id = tutorial_id
	current_tutorial = tutorials[tutorial_id]
	continue_label.new_text = "[right]Press [[Cross]] to continue.[/right]"
	title.text = tutorials[current_tutorial_id].title
	description.new_text = tutorials[current_tutorial_id].description
	image.texture = tutorials[current_tutorial_id].image
