extends RigidBody2D
class_name AguniAirCandle
var triggered: bool = false

@export var sound: PolyphonicAudio
@export var light: PointLight2D
@export var area_2d: Area2D
@export var animation: AnimationPlayer
const MAX_LIGHT: float = 2
const MIN_LIGHT: float = 1
const DURATION: float = 0.2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func triggerCandle() -> void:
	triggered = true
	sound.play_sound_effect_from_library("light")
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(light, "energy", MAX_LIGHT, DURATION)
	tween.tween_property(light, "energy", MIN_LIGHT, DURATION)
	area_2d.set_deferred("monitoring", false)
	animation.play("idle")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is OffensiveFirePillars or area.get_parent() is KamikazeRaven or area.get_parent() is SlaughtererFireball:
		triggerCandle()
