extends State
class_name CrowDying
var phase: int = 0
@export var revival_particles: CPUParticles2D
@export var sprite: Sprite2D
@export var sparkles: CPUParticles2D
var revival_tween: Tween
const REVIVAL_TWEEN_DURATION: float = 1
const REVIVAL_POSITION_OFFSET: Vector2 = Vector2(0, -150)
const MAX_FALLING_TIME: float = 7
var fall_automatically: bool

func enter():
	voice.play_sound_effect_from_library("dying")
	fall_automatically = false
	get_tree().create_timer(MAX_FALLING_TIME, false).timeout.connect(func(): fall_automatically = true)
	player.is_alive = false
	player.dash_frequency_timer.stop()
	player.velocity = Vector2.ZERO
	animation.play("dying_start")
	phase = 0
	
func Update(delta: float):
	if not animation.is_playing() and phase == 0:
		phase = 1
		animation.play("dying_loop")
		player.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
		player.set_collision_mask_value(1, true)
		player.set_collision_mask_value(13, true)
	
	if phase == 1 and (player.is_on_floor() or fall_automatically):
		sparkles.emitting = false
		animation.play("dying_fall")
		player.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		phase = 2
		
	if phase == 2 and not animation.is_playing() and player.stats.Stats["Hearts"] > player.stats.Stats["MHearts"]/4 and (not revival_tween or not revival_tween.is_running()):
		sprite.frame = 0
		player.global_position = Global.player.global_position + REVIVAL_POSITION_OFFSET
		print(Global.player.global_position)
		print(player.global_position)
		voice.play_sound_effect_from_library("revive")
		sparkles.emitting = true
		get_tree().create_timer(0.1, false).timeout.connect(func(): revival_particles.emitting = true)
		revival_tween = get_tree().create_tween()
		revival_tween.tween_property(sprite, "self_modulate", Color.WHITE, REVIVAL_TWEEN_DURATION)
		await revival_tween.finished
		player.dash_frequency_timer.start()
		Transitioned.emit(self, "idle")

func exit():
	player.is_hurt = false
	player.is_alive = true
	player.set_collision_mask_value(1, false)
	player.set_collision_mask_value(13, false)
	
func Physics_Update(delta: float):
	pass
