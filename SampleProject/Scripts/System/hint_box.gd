extends Control
class_name HintBox
@export var label: RichTextLabelWithButtons
@export var timer: Timer
@export var sound: PolyphonicMenuAudio
@export var animation: AnimationPlayer
var text: String
var time: float
var activate: bool = false

func _ready() -> void:
	Global.tutorial_box = self
	
func _process(delta: float) -> void:
	if activate:
		animation.play("popup")
		timer.wait_time = time
		label.controller_scheme = Global.game.controller_scheme
		label.new_text = text
		timer.start()
		sound.play_sound_effect_from_library("open")
		activate = false

func _on_timer_timeout() -> void:
	animation.play_backwards("popup")
