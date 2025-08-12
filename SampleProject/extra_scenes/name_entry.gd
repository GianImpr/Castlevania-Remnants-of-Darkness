extends Control
class_name NameEntry
@export var cursor: TextureRect
@export var letter_box: GridContainer
@export var name_container: HBoxContainer
@export var sound: PolyphonicMenuAudio
var current_pos: int = 0
const BUTTON_QUANTITY: int = 33
var current_name: String = ""
const MAX_NAME_SIZE: int = 8
const LETTER_MODULATE: Color = Color(1.5, 1.5, 1.5, 1)
const LETTER_SIZE: Vector2 = Vector2(64, 64)
const CURSOR_OFFSET: Vector2 = Vector2(16, 16)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cursor.global_position = letter_box.get_child(current_pos).global_position+CURSOR_OFFSET
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		current_pos += 1
		sound.play_sound_effect_from_library("cursor")
		updateCursorPosition()
	elif Input.is_action_just_pressed("ui_left"):
		current_pos -= 1
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
		
	
func addLetterToName():
	const TWEEN_DURATION: float = 0.3
	if letter_box.get_child(current_pos).text == "Back":
		removeLetterFromName()
		return
	elif letter_box.get_child(current_pos).text == "Ok":
		return
		#go to difficulty panel
	if name_container.get_child_count() >= MAX_NAME_SIZE:
		sound.play_sound_effect_from_library("denied")
		return
	sound.play_sound_effect_from_library("confirm")
	var new_letter: TextureRect = TextureRect.new()
	new_letter.texture = letter_box.get_child(current_pos).icon
	new_letter.modulate = Color.TRANSPARENT
	new_letter.custom_minimum_size = LETTER_SIZE
	current_name += letter_box.get_child(current_pos).text
	name_container.add_child(new_letter)
	get_tree().create_tween().tween_property(new_letter, "modulate", LETTER_MODULATE, TWEEN_DURATION)
	
func removeLetterFromName():
	if name_container.get_child_count() == 0:
		sound.play_sound_effect_from_library("denied")
		return
	var last_letter: TextureRect = name_container.get_child(name_container.get_child_count()-1)
	name_container.remove_child(last_letter)
	last_letter.queue_free()
	current_name.erase(current_name.length()-1)
	
func updateCursorPosition() -> void:
	current_pos = max(0, min(current_pos, BUTTON_QUANTITY-1))
	var new_position: Vector2 = letter_box.get_child(current_pos).global_position-CURSOR_OFFSET
	const ANIMATION_DURATION: float = 0.2
	get_tree().create_tween().tween_property(cursor, "global_position", new_position, ANIMATION_DURATION)
