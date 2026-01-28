@tool
extends Node2D
class_name DialogueBox

enum Emotions {
	STAY,
	NEUTRAL,
	ANNOYED,
	HAPPY,
	ANGRY,
	SAD
}

enum Character {
	LEFT,
	RIGHT
}

@export var test: bool:
	set(value):
		dialogue_entries = dialogue_test
		_startDialogue()
		
		
@export var dialogue_test: Array[Dialogue]
@export var go_ahead: bool
@export var left_character: Sprite2D
@export var right_character: Sprite2D
@export var character_name: Label
@export var text: RichTextLabel
@export var wait_timer: Timer
@export_multiline var dialogue_text: String
@export var sound: AudioStreamPlayer
@export var animation: AnimationPlayer
@export var cursor: Sprite2D
static var dialogue_entries: Array

const COMMA_WAIT_TIME: float = 0.3
const PERIOD_WAIT_TIME: float = 0.6
const NORMAL_DIALOGUE_WAIT_TIME: float = 0.03
const PREVIOUS_EXPRESSION_INDEX: int = 0
const CHARACTER_ANIMATION_INDEX: int = 1

var has_to_release_button: bool = false
var character_speaking: Character = Character.LEFT
var current_dialogue_entry: int = 0
static var active: bool = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		Global.dialogue_screen = self
	DialogueBoxTrigger.startDialogue = _startDialogue

func _process(delta: float) -> void:
	if active and text.visible_ratio != 1 and Input.is_action_just_pressed("ui_accept"):
		text.visible_ratio = 1
		has_to_release_button = true
		cursor.visible = true
		cursor.get_child(0).seek(0)
		wait_timer.stop()

	if active and not animation.is_playing() and (go_ahead or Input.is_action_just_pressed("ui_accept")) and text.visible_ratio == 1 and not has_to_release_button:
		go_ahead = false
		current_dialogue_entry += 1
		if current_dialogue_entry < dialogue_entries.size():
			setDialogueBox()
		else:
			_endDialogue()
			
	elif active and Input.is_action_just_pressed("menu") and not animation.is_playing():
		wait_timer.stop()
		_endDialogue()

	if Input.is_action_just_released("ui_accept"):
		has_to_release_button = false

func setDialogueBox() -> void:
	var entry: Dialogue = dialogue_entries[current_dialogue_entry]
	setCharacterName(Dialogue.Names.values()[entry.character], entry.hide_name)
	setText(entry.dialogue_text, entry.expression, entry.position)
	

func setCharacterName(name_text: String, hide_name: bool) -> void:
	if hide_name:
		character_name.text = "???"
	else:
		character_name.text = name_text

func setEmotion(emotion, character) -> void:
	if emotion == 0:
		return
		
	if character == Character.LEFT:
		left_character.get_child(PREVIOUS_EXPRESSION_INDEX).frame = left_character.frame
		left_character.frame = emotion-1
		left_character.get_child(CHARACTER_ANIMATION_INDEX).play("change_expression")
	else:
		right_character.get_child(PREVIOUS_EXPRESSION_INDEX).frame = right_character.frame
		right_character.frame = emotion-1
		right_character.get_child(CHARACTER_ANIMATION_INDEX).play("change_expression")

func setText(dialogue: String, emotion: Dialogue.Emotions = Dialogue.Emotions.KEEP_CURRENT, character = character_speaking) -> void:
	if character != character_speaking:
		swapChar(character)
		
	if character == Character.LEFT and left_character.texture == null or \
	character == Character.RIGHT and right_character.texture == null:
		setCharacterPortrait()
		
	if emotion != Emotions.STAY:
		setEmotion(emotion, character)
		
		
	text.visible_characters = 0
	cursor.visible = false
	text.text = tr(dialogue)
	wait_timer.wait_time = NORMAL_DIALOGUE_WAIT_TIME
	wait_timer.start()
	
func swapChar(character: Character) -> void:
	if character_speaking == character:
		return
	
	character_speaking = character
	if character == Character.LEFT:
		animation.play_backwards("swap")
	else:
		animation.play("swap")
		
func _on_wait_timeout() -> void:
	if has_to_release_button:
		return
		
	if text.get_total_character_count() == text.visible_characters:
		cursor.visible = true
		cursor.get_child(0).seek(0)
		wait_timer.stop()
		return
		
	text.visible_characters += 1
	
	match text.text[text.visible_characters-1]:
		",":
			wait_timer.wait_time = COMMA_WAIT_TIME
		".":
			wait_timer.wait_time = PERIOD_WAIT_TIME
		"?":
			if text.get_total_character_count()-1 > text.visible_characters and text.text[text.visible_characters] == "!":
				wait_timer.wait_time = NORMAL_DIALOGUE_WAIT_TIME
			else:
				wait_timer.wait_time = PERIOD_WAIT_TIME
				

		"!":
			wait_timer.wait_time = PERIOD_WAIT_TIME
		_:
			wait_timer.wait_time = NORMAL_DIALOGUE_WAIT_TIME
			
	if text.visible_characters == text.get_total_character_count():
		wait_timer.wait_time = NORMAL_DIALOGUE_WAIT_TIME
		
	if text.visible_characters % 2 == 0:
		sound.play()
	wait_timer.start()

func _endDialogue() -> void:
	left_character.get_child(PREVIOUS_EXPRESSION_INDEX).frame = left_character.frame
	right_character.get_child(PREVIOUS_EXPRESSION_INDEX).frame = right_character.frame
	character_name.visible = false
	text.visible = false
	cursor.visible = false
	animation.play_backwards("dismiss")
	await animation.animation_finished
	active = false
	left_character.texture = null
	left_character.get_child(PREVIOUS_EXPRESSION_INDEX).texture = null
	right_character.texture = null
	right_character.get_child(PREVIOUS_EXPRESSION_INDEX).texture = null
	if not Engine.is_editor_hint():
		Global.HUD.visible = true
		Global.player.unfreeze()
	
func _startDialogue() -> void:
	if not Engine.is_editor_hint():
		Global.player.freeze()
		Global.HUD.visible = false
		
	active = true
	current_dialogue_entry = 0
	
	if dialogue_entries.size() == 0:
		push_error("There are no dialogue entries")
	
	setCharacterPortrait()
	
	left_character.get_child(PREVIOUS_EXPRESSION_INDEX).frame = left_character.frame
	right_character.get_child(PREVIOUS_EXPRESSION_INDEX).frame = right_character.frame
	animation.play("show")
	await animation.animation_finished
	setDialogueBox()
	character_name.visible = true
	text.visible = true

func setCharacterPortrait() -> void:
	var pos_tween: Tween = get_tree().create_tween()
	const INITIAL_LEFT_POSITION: Vector2 = Vector2(-120, 226)
	const INITIAL_RIGHT_POSITION: Vector2 = Vector2(984, 226)
	const POSITION_OFFSET: float = 240
	const SELF_MODULATE_DELAY: float = 0.2
	const POS_TWEEN_DURATION: float = 0.3
	const SELF_MODULATE_TWEEN_DURATION: float = 0.6
	
	if dialogue_entries[current_dialogue_entry].position == Dialogue.Position.LEFT:
		left_character.texture = load(Dialogue.Sprites.values()[dialogue_entries[current_dialogue_entry].character])
		if left_character.get_child(PREVIOUS_EXPRESSION_INDEX).texture == null:
			left_character.self_modulate = Color.TRANSPARENT
			pos_tween.tween_property(left_character, "position", Vector2(INITIAL_LEFT_POSITION.x+POSITION_OFFSET, INITIAL_LEFT_POSITION.y), POS_TWEEN_DURATION).from(INITIAL_LEFT_POSITION)
			get_tree().create_timer(SELF_MODULATE_DELAY).timeout.connect(func(): get_tree().create_tween().tween_property(left_character, "self_modulate", Color.WHITE, SELF_MODULATE_TWEEN_DURATION))
			left_character.get_child(PREVIOUS_EXPRESSION_INDEX).texture = left_character.texture
	else:
		right_character.texture = load(Dialogue.Sprites.values()[dialogue_entries[current_dialogue_entry].character])
		if right_character.get_child(PREVIOUS_EXPRESSION_INDEX).texture == null:
			right_character.self_modulate = Color.TRANSPARENT
			pos_tween.tween_property(right_character, "position", Vector2(INITIAL_RIGHT_POSITION.x-POSITION_OFFSET, INITIAL_RIGHT_POSITION.y), POS_TWEEN_DURATION).from(INITIAL_RIGHT_POSITION)
			get_tree().create_timer(SELF_MODULATE_DELAY).timeout.connect(func(): get_tree().create_tween().tween_property(right_character, "self_modulate", Color.WHITE, SELF_MODULATE_TWEEN_DURATION))
			right_character.get_child(PREVIOUS_EXPRESSION_INDEX).texture = right_character.texture
			
