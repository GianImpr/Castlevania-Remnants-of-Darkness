extends State
class_name HectorDying
@export var FLOATING_SPEED: Vector2
@export var hurtbox: CollisionShape2D
@export var timer_reset: Timer
@export var blood: CPUParticles2D
var can_perfect_guard: bool = false
const HEIGHT_DECELERATION: float = 0.95
const FADE_SCREEN_FADE_IN_COLOR: Color = Color(1,1,1,1)
const FADE_IN_DURATION: float = 0.5


func enter():
	animation.play("dying", -1)
	voice.play_sound_effect_from_library("Dead")
	player.velocity = FLOATING_SPEED
	timer_reset.start()
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	player.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	player.velocity.y *= HEIGHT_DECELERATION
	hurtbox.disabled = true
	
func _on_reset_timeout() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(Global.fade_screen, "modulate", FADE_SCREEN_FADE_IN_COLOR, FADE_IN_DURATION)
	await tween.finished
	Global.toTitleScreen()
