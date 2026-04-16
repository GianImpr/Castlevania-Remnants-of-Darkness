extends State
class_name CrowSpawn
@export var revival_particles: CPUParticles2D
@export var sprite: Sprite2D
@export var sparkles: CPUParticles2D
var revival_tween: Tween
const REVIVAL_TWEEN_DURATION: float = 1
const REVIVAL_POSITION_OFFSET: Vector2 = Vector2(0, -150)
const MAX_FALLING_TIME: float = 7

func Update(_delta: float):
	if player.stats.Stats["Hearts"] > player.stats.Stats["MHearts"]/4 and (not revival_tween or not revival_tween.is_running()) and not player.is_alive:
		player.is_alive = true
		sprite.frame = 0
		player.global_position = Global.player.global_position + REVIVAL_POSITION_OFFSET
		voice.play_sound_effect_from_library("revive")
		sparkles.emitting = true
		get_tree().create_timer(0.1, false).timeout.connect(func(): revival_particles.emitting = true)
		revival_tween = get_tree().create_tween()
		revival_tween.tween_property(player, "modulate", Color.WHITE, REVIVAL_TWEEN_DURATION)
		await revival_tween.finished
		Transitioned.emit(self, "idle")
		player.dash_frequency_timer.start()
