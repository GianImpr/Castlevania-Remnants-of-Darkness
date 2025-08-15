extends Control
class_name Intro
@export var game_scene: PackedScene
@export var music_player: PolyphonicMenuAudio
@export var sound: PolyphonicMenuAudio
var tween: Tween
const FADE_OUT_DURATION: float = 1
const SILENT_VOLUME: int = -80

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		tween = get_tree().create_tween()
		tween.set_parallel()
		tween.tween_property(self, "modulate", Color.BLACK, FADE_OUT_DURATION)
		tween.tween_property(sound, "volume_db", SILENT_VOLUME, FADE_OUT_DURATION)
		tween.tween_property(music_player, "volume_db", SILENT_VOLUME, FADE_OUT_DURATION)
		tween.finished.connect(startGame)


func startGame():
	get_tree().change_scene_to_packed(game_scene)
