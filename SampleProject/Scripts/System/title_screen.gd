extends Control
@export var animation: AnimationPlayer
@export var loading_screen: PackedScene
@export var save_label: Label
@export var difficulty_label: Label

func _process(delta: float) -> void:
	if not animation.is_playing():
		if Input.is_action_just_pressed("menu"):
			animation.play("disappear")

func startLoadingScreen():
	get_tree().change_scene_to_packed(loading_screen)
