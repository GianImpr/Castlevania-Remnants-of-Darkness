extends State
class_name HectorDying
@export var FLOATING_SPEED: Vector2
@export var hurtbox: CollisionShape2D
@export var timer_reset: Timer
@export var blood: CPUParticles2D
const RECOIL_SPEED: Vector2 = Vector2(250, -350)
const HEIGHT_DECELERATION: float = 0.95
var can_perfect_guard: bool = false
const FADE_SCREEN_FADE_IN_COLOR: Color = Color(1,1,1,1)
const FADE_MUSIC_DURATION: float = 2.5
var playing_death_anim: bool = false

func _ready() -> void:
	HectorPetrified.resetGame = _on_reset_timeout

func enter():
	blood.emitting = false
	playing_death_anim = false
	if player.drowning:
		animation.play("dying_drowning", -1)
	else:
		if not player.is_on_floor():
			animation.play("hurt_air")
			timer_reset.start()
			player.velocity.x = RECOIL_SPEED.x * player.facing_position * (-1)
			player.velocity.y = RECOIL_SPEED.y
		else:
			animation.play("dying")
			voice.play_sound_effect_from_library("Dead")
			playing_death_anim = true
			timer_reset.start()
			player.velocity.x = 0
			player.velocity.y = 0
	Global.music_player.fadeMusic(FADE_MUSIC_DURATION)
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	hurtbox.disabled = true
	
	if player.is_on_floor() and not playing_death_anim:
		player.velocity.x = 0
		player.velocity.y = 0
		playing_death_anim = true
		animation.play("dying")
		voice.play_sound_effect_from_library("Dead")
		timer_reset.start()
	
func _on_reset_timeout() -> void:
	Global.game_over_screen.showScreen()
	get_tree().paused = true
