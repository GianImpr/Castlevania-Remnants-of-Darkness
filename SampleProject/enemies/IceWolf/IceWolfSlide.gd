extends State
class_name IceWolfSlide
const SPEED: float = 450
var acceleration_tween: Tween
const ACCELERATION_DURATION: float = 0.1
const DECELERATION_DURATION: float = 0.8
@export var dash: CollisionShape2D

func enter():
	animation.play("slide")
	sound.play_sound_effect_from_library("slide")
	
func exit():
	if acceleration_tween:
		acceleration_tween.kill()
	player.velocity.x = 0
	dash.set_deferred("disabled", true)

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass

func activateTween() -> void:
	acceleration_tween = get_tree().create_tween()
	acceleration_tween.tween_property(player, "velocity:x", SPEED*player.facing_position, ACCELERATION_DURATION)
	acceleration_tween.tween_property(player, "velocity:x", 0, DECELERATION_DURATION)
