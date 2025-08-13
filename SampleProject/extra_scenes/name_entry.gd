extends Control
class_name NameEntry
@export var cursor: TextureRect
@export var letter_box: GridContainer
@export var name_container: HBoxContainer
@export var sound: PolyphonicMenuAudio
@export var animation: AnimationPlayer
@export var confirm_panel_animation: AnimationPlayer
@export var confirm_panel: VBoxContainer
var current_pos: int = 0
var asking_confirm: bool = false
const BUTTON_QUANTITY: int = 33
var current_name: String = ""
const MAX_NAME_SIZE: int = 8
const LETTER_MODULATE: Color = Color(1.5, 1.5, 1.5, 1)
const LETTER_SIZE: Vector2 = Vector2(64, 64)
const CURSOR_OFFSET: Vector2 = Vector2(16, 16)
const UNAVAILABLE_BUTTON_MODULATE: Color = Color.DIM_GRAY
const OK_BUTTON_INDEX: int = 32
const BACK_BUTTON_INDEX: int = 31

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = PROCESS_MODE_INHERIT
	cursor.global_position = letter_box.get_child(current_pos).global_position+CURSOR_OFFSET
	letter_box.get_child(OK_BUTTON_INDEX).modulate = UNAVAILABLE_BUTTON_MODULATE
	letter_box.get_child(BACK_BUTTON_INDEX).modulate = UNAVAILABLE_BUTTON_MODULATE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if asking_confirm or animation.is_playing() or confirm_panel_animation.is_playing():
		return
		
	if Input.is_action_just_pressed("ui_right"):
		current_pos += 1
		if current_pos % letter_box.columns == 0:
			current_pos -= letter_box.columns
		sound.play_sound_effect_from_library("cursor")
		updateCursorPosition()
	elif Input.is_action_just_pressed("ui_left"):
		current_pos -= 1
		if current_pos % letter_box.columns == letter_box.columns-1 or current_pos == -1:
			current_pos += letter_box.columns
		sound.play_sound_effect_from_library("cursor")
		updateCursorPosition()
	elif Input.is_action_just_pressed("ui_down"):
		current_pos += letter_box.columns
		sound.play_sound_effect_from_library("cursor")
		updateCursorPosition()
	elif Input.is_action_just_pressed("ui_up"):
		current_pos -= letter_box.columns
		sound.play_sound_effect_from_library("cursor")
		updateCursorPosition()
	elif Input.is_action_just_pressed("ui_accept"):
		addLetterToName()
	elif Input.is_action_just_pressed("ui_cancel"):
		removeLetterFromName()
	elif Input.is_action_just_pressed("menu"):
		current_pos = BUTTON_QUANTITY-1
		sound.play_sound_effect_from_library("cursor")
		updateCursorPosition()
		
	
func addLetterToName():
	const TWEEN_DURATION: float = 0.3
	if letter_box.get_child(current_pos).text == "Back":
		if current_name.length() > 0:
			sound.play_sound_effect_from_library("confirm")
		removeLetterFromName()
		return
	elif letter_box.get_child(current_pos).text == "Ok":
		if current_name.length() == 0:
			sound.play_sound_effect_from_library("denied")
		else:
			sound.play_sound_effect_from_library("confirm")
			askConfirm()
		return
		
	if name_container.get_child_count() >= MAX_NAME_SIZE:
		sound.play_sound_effect_from_library("denied")
		return
		
	sound.play_sound_effect_from_library("confirm")
	var new_letter: TextureRect = TextureRect.new()
	new_letter.texture = letter_box.get_child(current_pos).icon
	new_letter.modulate = Color.TRANSPARENT
	new_letter.custom_minimum_size = LETTER_SIZE
	
	if current_name.length() == 0:
		letter_box.get_child(OK_BUTTON_INDEX).modulate = LETTER_MODULATE
		letter_box.get_child(BACK_BUTTON_INDEX).modulate = LETTER_MODULATE

	current_name += letter_box.get_child(current_pos).text
	name_container.add_child(new_letter)
	var animation_tween: Tween = get_tree().create_tween()
	animation_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	animation_tween.tween_property(new_letter, "modulate", LETTER_MODULATE, TWEEN_DURATION)
	
func removeLetterFromName():
	if name_container.get_child_count() == 0:
		sound.play_sound_effect_from_library("denied")
		return
	var last_letter: TextureRect = name_container.get_child(name_container.get_child_count()-1)
	name_container.remove_child(last_letter)
	last_letter.queue_free()
	current_name = current_name.left(current_name.length()-1)
	
	if current_name.length() == 0:
		letter_box.get_child(OK_BUTTON_INDEX).modulate = UNAVAILABLE_BUTTON_MODULATE
		letter_box.get_child(BACK_BUTTON_INDEX).modulate = UNAVAILABLE_BUTTON_MODULATE

	
func updateCursorPosition() -> void:
	current_pos = max(0, min(current_pos, BUTTON_QUANTITY-1))
	var new_position: Vector2 = letter_box.get_child(current_pos).global_position-CURSOR_OFFSET
	const ANIMATION_DURATION: float = 0.2
	var animation_tween: Tween = get_tree().create_tween()
	animation_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	animation_tween.tween_property(cursor, "global_position", new_position, ANIMATION_DURATION)

func askConfirm() -> void:
	const YES_BUTTON: int = 0
	asking_confirm = true
	sound.play_sound_effect_from_library("popup")
	confirm_panel_animation.play("ask_confirm")
	confirm_panel.get_child(YES_BUTTON).grab_focus()
	
func closePanel(button: Button) -> void:
	button.release_focus()
	confirm_panel_animation.play_backwards("ask_confirm")
	asking_confirm = false

func _on_yes_pressed() -> void:
	const YES_BUTTON: int = 0
	confirm_panel.get_child(YES_BUTTON).release_focus()
	closePanel(confirm_panel.get_child(YES_BUTTON))
	animation.play("confirm")
	sound.play_sound_effect_from_library("confirm")


func _on_no_pressed() -> void:
	const NO_BUTTON: int = 1
	closePanel(confirm_panel.get_child(NO_BUTTON))
	sound.play_sound_effect_from_library("confirm")
	
func _on_button_focused() -> void:
	sound.play_sound_effect_from_library("cursor")
