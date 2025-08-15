extends Control
class_name Intro
@export var game_scene: PackedScene
@export var music_player: PolyphonicMenuAudio
@export var sound: PolyphonicMenuAudio
@export var text: Label
var tween: Tween
const FADE_OUT_DURATION: float = 1
const SILENT_VOLUME: int = -80
const INITIAL_TEXT_POSITION: float = 480
const BASE_FINAL_TEXT_POSITION: float = -20
const TEXT_DURATION: float = 75
var text_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_tween = get_tree().create_tween()
	text.position.y = INITIAL_TEXT_POSITION
	text_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	text_tween.tween_property(text, "position", Vector2(text.position.x, BASE_FINAL_TEXT_POSITION-text.size.y), TEXT_DURATION)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		tween = get_tree().create_tween()
		tween.set_parallel()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(self, "modulate", Color.BLACK, FADE_OUT_DURATION)
		tween.tween_property(sound, "volume_db", SILENT_VOLUME, FADE_OUT_DURATION)
		tween.tween_property(music_player, "volume_db", SILENT_VOLUME, FADE_OUT_DURATION)
		tween.finished.connect(startGame)


func startGame():
	if text_tween != null and text_tween.is_running():
		text_tween.kill()
	get_tree().change_scene_to_packed(game_scene)
