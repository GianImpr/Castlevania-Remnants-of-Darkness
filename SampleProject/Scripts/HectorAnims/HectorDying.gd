extends State
class_name HectorDying
@export var FLOATING_SPEED: Vector2
@export var hurtbox: CollisionShape2D
@export var timer_reset: Timer
@export var blood: CPUParticles2D
var can_perfect_guard: bool = false
const HEIGHT_DECELERATION: float = 0.95
const FADE_SCREEN_FADE_IN_COLOR: Color = Color(1,1,1,1)
const FADE_MUSIC_DURATION: float = 2.5

func _ready() -> void:
	HectorPetrified.resetGame = _on_reset_timeout

func enter():
	if player.drowning:
		animation.play("dying_drowning", -1)
	else:
		animation.play("dying", -1)
		voice.play_sound_effect_from_library("Dead")
	player.velocity = FLOATING_SPEED
	timer_reset.start()
	Global.music_player.fadeMusic(FADE_MUSIC_DURATION)
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	player.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	player.velocity.y *= HEIGHT_DECELERATION
	hurtbox.disabled = true
	
func _on_reset_timeout() -> void:
	Global.game_over_screen.showScreen()
	get_tree().paused = true
