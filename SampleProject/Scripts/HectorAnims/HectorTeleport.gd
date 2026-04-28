extends State
class_name HectorTeleport
var can_perfect_guard: bool = false
@export var teleport_particles: GPUParticles2D
const JULIA_SHOP_PATH: String = "res://SampleProject/Maps/ShopRoom/shop_room.tscn"
const DEFAULT_POSITION: Vector2 = Vector2(871,346)
var phase: int
var vanish_tween: Tween
const VANISH_COLOR: Color = Color(1,1,0,0)
const VANISH_DURATION: float = 1
const DELAY_SECONDS: float = 0.5

func enter():
	player.velocity = Vector2.ZERO
	animation.play("pose")
	teleport_particles.emitting = true
	vanish_tween = get_tree().create_tween()
	vanish_tween.tween_property(player.sprite, "modulate", VANISH_COLOR, VANISH_DURATION)
	sound.play_sound_effect_from_library("teleport")
	await teleport_particles.finished
	Global.change_area.emit(JULIA_SHOP_PATH, DEFAULT_POSITION)
	await get_tree().create_timer(DELAY_SECONDS).timeout
	player.facing_position = -1
	player.sprite.flip_h = true
	teleport_particles.emitting = true
	vanish_tween = get_tree().create_tween()
	vanish_tween.tween_property(player.sprite, "modulate", Color.WHITE, VANISH_DURATION).from(VANISH_COLOR)
	sound.play_sound_effect_from_library("teleport")
	await teleport_particles.finished
	animation.play_backwards("pose")
	await animation.animation_finished
	Transitioned.emit(self, "idle")
