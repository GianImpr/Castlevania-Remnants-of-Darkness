extends AnimatableBody2D
@export var animation: AnimationPlayer
@export var sound: PolyphonicAudio
var current_state = "idle"

func _physics_process(delta: float) -> void:
	if not animation.is_playing() and current_state == "activate":
		current_state = "moving"
		animation.play("move")
		
		
		
	

func _on_activationbox_body_entered(body: Node2D) -> void:
	if current_state == "idle":
		animation.play("activate")
		current_state = "activate"
		sound.play_sound_effect_from_library("activate")
