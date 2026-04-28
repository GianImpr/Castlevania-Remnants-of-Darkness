extends Control
@export var animation: AnimationPlayer
@export var loading_screen: PackedScene
@export var save_label: Label
@export var buttons: VBoxContainer
@export var sound: PolyphonicMenuAudio

const TWEEN_DURATION: float = 1
const BUTTON_QUANTITY: int = 2
var cur_button: int = 0
var tween: Tween

enum COMMANDS {
	NEW_GAME,
	CONTINUE,
	OPTIONS,
	SOUND_SELECT
}

func _ready() -> void:
	highlightFocusedButton(0)
	SavingScreen.deleteBattleCheckpoint()

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

func selectOption():
	if tween != null:
		tween.kill()
		
	match cur_button:
		COMMANDS.NEW_GAME:
			get_tree().change_scene_to_packed(loading_screen)
			Global.load_data = false
		COMMANDS.CONTINUE:
			get_tree().change_scene_to_packed(loading_screen)
			Global.load_data = true
	
func highlightFocusedButton(previous_button: int) -> void:
	if tween != null:
		tween.kill()
	buttons.get_child(previous_button).modulate = Color.WHITE
	tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(buttons.get_child(cur_button), "modulate", Color.DARK_RED, TWEEN_DURATION).from(Color.RED)
	tween.tween_property(buttons.get_child(cur_button), "modulate", Color.RED, TWEEN_DURATION).from(Color.DARK_RED)
	tween.finished.connect(highlightFocusedButton.bind(cur_button-1))
