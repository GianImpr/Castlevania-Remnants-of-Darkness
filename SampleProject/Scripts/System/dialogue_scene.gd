extends Node2D
class_name DialogueBox

enum Emotions {
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

@export var left_character: Sprite2D
@export var right_character: Sprite2D
@export var character_name: Label
@export var text: RichTextLabel

func setEmotion(emotion: Emotions, character: Character) -> void:
	if character == Character.LEFT:
		left_character.frame = emotion
	else:
		right_character.frame = emotion
		
