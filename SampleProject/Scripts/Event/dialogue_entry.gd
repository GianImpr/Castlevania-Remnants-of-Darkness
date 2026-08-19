extends Resource
class_name Dialogue

enum Character {
	HECTOR,
	CARMILLA,
	TREVOR,
	JULIA
}

enum Position {
	LEFT,
	RIGHT
}

const Names = {
	HECTOR = "Hector", 
	CARMILLA = "Carmilla",
	TREVOR = "Trevor",
	JULIA = "Julia"
}

const Sprites = {
	HECTOR = "res://assets/sprites/HUD/Faces/Hector/HalfBody.png",
	CARMILLA = "res://assets/sprites/HUD/Faces/Carmilla/HalfBody.png",
	TREVOR = "res://assets/sprites/HUD/Faces/Trevor/HalfBody.png",
	JULIA = "res://assets/sprites/HUD/Faces/Julia/HalfBody.png"
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
@export var hide_name: bool
@export var expression: Emotions
@export_multiline var dialogue_text: String
@export var position: Position
@export_range(0, 20, 0.1, "suffix:s") var dismiss_for: float = 0
