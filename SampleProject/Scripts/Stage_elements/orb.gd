extends Node2D
class_name Orb
@export var animation: AnimationPlayer
@export var glowing_particles: GPUParticles2D
@export var spawn_particles: GPUParticles2D
@export var orb_sprite: Sprite2D
@export var point_light: PointLight2D
@export var orb_color: OrbColor
@export var sound: PolyphonicAudio
@export var pickup_flag_id: int
@export var beat_sound_timer: Timer
var spawned: bool = false
const orb_texture_path: String = "res://assets/sprites/Items/Orbs/"

enum OrbColor {
	RED,
	CYAN
}

func _ready() -> void:
	if Global.player.stats.picked_items[pickup_flag_id]:
		queue_free()
		
	var particles_color: Color
	var orb_texture_file: String
	match orb_color:
		OrbColor.RED:
			particles_color = Color(1, 0, 0, 0.75)
			orb_texture_file = "RedOrb.png"
		OrbColor.CYAN:
			particles_color = Color(0, 1, 1, 0.75)
			orb_texture_file = "CyanOrb.png"
	orb_sprite.texture = load(orb_texture_path + orb_texture_file)
	
func _process(delta: float) -> void:
	if animation.is_playing() and animation.current_animation_position < 6 and animation.current_animation == "spawn":
		Global.camera.random_strength = 1
		Global.camera.apply_shake()

func _on_beat_sound_delay_timeout() -> void:
	sound.play_sound_effect_from_library("beat")
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(point_light, "energy", 1, 1.2)
	await tween.finished
	tween = get_tree().create_tween()
	tween.tween_property(point_light, "energy", 3, 1.2)
	
func _spawnOrb() -> void:
	spawned = true
	animation.play("spawn")
	Global.player.freeze()
	await animation.animation_finished
	beat_sound_timer.start()
	animation.play("floating")
	Global.player.unfreeze()
	
func collecting() -> void:
	Global.player.stats.picked_items[pickup_flag_id] = true
	beat_sound_timer.stop()
	const HEALING_AMOUNT: int = 9999
	Global.player.heal_innocent(HEALING_AMOUNT)
	Global.player.stats.Stats["HP"] = Global.player.stats.Stats["MHP"]
	Global.player.stats.Stats["MP"] = Global.player.stats.Stats["MMP"]
	sound.play_sound_effect_from_library("collect")
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
	get_tree().paused = false
	Global.screen = Global.ScreenType.NONE

func _on_area_2d_body_entered(body: Node2D) -> void:
	animation.play("collected")
