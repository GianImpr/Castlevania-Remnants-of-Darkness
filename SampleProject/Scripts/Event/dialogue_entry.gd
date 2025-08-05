extends Resource
class_name Dialogue

enum Character {
	HECTOR
}

enum Position {
	LEFT,
	RIGHT
}

const Names = {
	HECTOR = "Hector"
}

const Sprites = {
	HECTOR = "res://assets/sprites/HUD/Faces/Hector/HalfBody.png"
}

enum Emotions {
	KEEP_CURRENT,
	NEUTRAL,
	ANNOYED,
	HAPPY,
	ANGRY,
	SAD
}

@export var character: Character
@export var expression: Emotions
@export_multiline var dialogue_text: String
@export var position: Position
