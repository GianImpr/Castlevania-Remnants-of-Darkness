extends Control
class_name HintBox
@export var label: RichTextLabelWithButtons
@export var timer: Timer
@export var sound: PolyphonicMenuAudio
@export var animation: AnimationPlayer
@export var is_description_box: bool = false
var text: String
var time: float
var activate: bool = false

func _ready() -> void:
	if not is_description_box:
		Global.tutorial_box = self
	else:
		Global.description_box = self
		
	
func _process(delta: float) -> void:
	if activate:
		popup(text, time)
		activate = false
	
	#Only use for videos
	if is_description_box and Input.is_action_just_pressed("text") and false:
		popup(label.text, 4)

func _on_timer_timeout() -> void:
	animation.play_backwards("popup")

func popup(message: String, duration: float) -> void:
		animation.play("popup")
		timer.wait_time = duration
		label.controller_scheme = Global.game.controller_scheme
		label.new_text = message
		timer.start()
		sound.play_sound_effect_from_library("open")
	
func isActive() -> bool:
	return not timer.is_stopped()
