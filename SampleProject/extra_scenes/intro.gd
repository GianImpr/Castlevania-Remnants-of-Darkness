extends Control
class_name Intro
@export var game_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func startGame():
	get_tree().change_scene_to_packed(game_scene)
