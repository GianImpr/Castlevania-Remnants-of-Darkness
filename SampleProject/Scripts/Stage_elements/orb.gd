extends Node2D
class_name Orb
@export var animation: AnimationPlayer
@export var imploding_particles: GPUParticles2D
@export var glowing_particles: GPUParticles2D
@export var spawn_particles: GPUParticles2D
@export var orb_sprite: Sprite2D
@export var point_light: PointLight2D
@export var orb_color: OrbColor
@export var sound: PolyphonicAudio
@export var pickup_flag_id: int
@export var beat_sound_timer: Timer
@export var item_id: int
@export var spawn_automatically: bool = false
var spawned: bool = false
const orb_texture_path: String = "res://assets/sprites/Items/Pickups/Orbs/"
const AUTOMATIC_SPAWN_DELAY: float = 0.1
const BEFORE_APPEARING: float = 6
const CAMERA_STRENGTH: float = 1
const ENERGY_DURATION: float = 1.2
const MIN_BEAT_ENERGY: float = 1
const MAX_BEAT_ENERGY: float = 3

enum OrbColor {
	RED,
	CYAN
}

const Colors = {
	RED = Color(1, 0, 0, 0.773),
	CYAN = Color(0, 1, 1, 0.773)
}

func _ready() -> void:
	if Global.player.stats.picked_items[pickup_flag_id]:
		queue_free()
		
	var orb_texture_file: String
	match orb_color:
		OrbColor.RED:
			imploding_particles.self_modulate = Colors.RED
			spawn_particles.self_modulate = Colors.RED
			glowing_particles.self_modulate = Colors.RED
			orb_texture_file = "RedOrb.png"
		OrbColor.CYAN:
			imploding_particles.self_modulate = Colors.CYAN
			spawn_particles.self_modulate = Colors.CYAN
			spawn_particles.self_modulate = Colors.CYAN
			orb_texture_file = "CyanOrb.png"
	orb_sprite.texture = load(orb_texture_path + orb_texture_file)
	
	if spawn_automatically and not Global.player.stats.picked_items[pickup_flag_id]:
		get_tree().create_timer(AUTOMATIC_SPAWN_DELAY).timeout.connect(_spawnOrb)
	
func _process(delta: float) -> void:
	if animation.is_playing() and animation.current_animation_position < BEFORE_APPEARING and animation.current_animation == "spawn":
		Global.camera.random_strength = CAMERA_STRENGTH
		Global.camera.apply_shake()

func _on_beat_sound_delay_timeout() -> void:
	sound.play_sound_effect_from_library("beat")
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(point_light, "energy", MIN_BEAT_ENERGY, ENERGY_DURATION)
	await tween.finished
	tween = get_tree().create_tween()
	tween.tween_property(point_light, "energy", MAX_BEAT_ENERGY, ENERGY_DURATION)
	
func _spawnOrb() -> void:
	spawned = true
	animation.play("spawn")
	Global.player.freeze()
	if Global.screen == Global.ScreenType.NONE:
		Global.screen = Global.ScreenType.EVENT
	await animation.animation_finished
	beat_sound_timer.start()
	animation.play("floating")
	Global.player.unfreeze()
	
func collecting() -> void:
	Global.player.stats.picked_items[pickup_flag_id] = true
	beat_sound_timer.stop()
	const HEALING_AMOUNT: int = 9999
	Global.player.heal_innocent(HEALING_AMOUNT)
	Global.player.stats.addItem(item_id, Global.player.stats.skill_inventory)
	Global.player.stats.Stats["HP"] = Global.player.stats.Stats["MHP"]
	Global.player.stats.Stats["MP"] = Global.player.stats.Stats["MMP"]
	sound.play_sound_effect_from_library("collect")
	if Global.screen == Global.ScreenType.NONE:
		Global.screen = Global.ScreenType.EVENT
	get_tree().paused = true
	var freeze_screen_timer: Timer = Timer.new()
	freeze_screen_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	const FREEZE_DURATION: float = 1
	add_child(freeze_screen_timer)
	freeze_screen_timer.timeout.connect(unfreeze_game)
	freeze_screen_timer.start(FREEZE_DURATION)
	glowing_particles.emitting = false
	
func unfreeze_game() -> void:
	if Global.screen == Global.ScreenType.EVENT:
		get_tree().paused = false
		Global.screen = Global.ScreenType.NONE

func _on_area_2d_body_entered(body: Node2D) -> void:
	animation.play("collected")
