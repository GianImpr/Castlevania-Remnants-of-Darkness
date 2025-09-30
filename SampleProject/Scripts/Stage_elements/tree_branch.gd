extends Node2D
class_name TreeBranch
@export var event_ID: int
@export var explosion_sound_timer: Timer
@export var sound: PolyphonicAudio
@export var animation: AnimationPlayer
const EXPLOSION_SOUNDS: int = 14
var cur_explosions_left: int

func explosionSound() -> void:
	sound.play_sound_effect_from_library("explosion")
	cur_explosions_left -= 1
	if cur_explosions_left == 0:
		explosion_sound_timer.stop()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cur_explosions_left = EXPLOSION_SOUNDS
	explosion_sound_timer.timeout.connect(explosionSound)
	if Global.player.stats.event_flags[event_ID]:
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	Global.player.stats.event_flags[event_ID] = true
	animation.play("exploding")
	sound.play_sound_effect_from_library("explosion")
	explosion_sound_timer.start()
