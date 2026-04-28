extends Control
class_name DifficultySelection
@export var options: VBoxContainer
@export var prologue_scene: PackedScene
@export var sound: PolyphonicMenuAudio
@export var animation: AnimationPlayer

@export var difficulty_description: Label
@export var difficulty_image: TextureRect

const DESCRIPTIONS: Array[String] = ["SIMPLIFIED_DIFFICULTY_DESC", "STANDARD_DIFFICULTY_DESC", "CRAZY_DIFFICULTY_DESC"]
@export var difficulty_images: Array[CompressedTexture2D]

enum DifficultyIndex {
	SIMPLIFIED,
	STANDARD,
	CRAZY
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button in options.get_children():
		(button as Button).focus_entered.connect(_on_focused.bind(button))
		(button as Button).pressed.connect(_on_pressed.bind(button))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_focused(which: Button) -> void:
	if animation.is_playing() and animation.current_animation == "vanish":
		return
	sound.play_sound_effect_from_library("cursor")
	updateDescription(which)
	
func _on_pressed(which: Button) -> void:
	if animation.is_playing() and animation.current_animation == "vanish":
		return
	sound.play_sound_effect_from_library("confirm")
	Global.new_game_difficulty = which.get_index()
	Global.load_data = false
	Global.save_destination = ""
	Global.save_file_to_load = ""
	animation.play("vanish")
	
func updateDescription(which: Button) -> void:
	difficulty_description.text = tr(DESCRIPTIONS[which.get_index()])
	difficulty_image.texture = difficulty_images[which.get_index()]
	
func startGame():
	get_tree().change_scene_to_packed(prologue_scene)
