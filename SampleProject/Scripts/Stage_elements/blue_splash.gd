extends Hazard
class_name BlueSplash

@export_range(0.1, 3, 0.1, "suffix:s") var initial_delay: float
@export_range(0.1, 3, 0.1, "suffix:s") var warn_after: float
@export_range(0.1, 3, 0.1, "suffix:s") var shoot_after_warn: float
@export var warn_particles: CPUParticles2D
@export var animation: AnimationPlayer
@export var sound: PolyphonicAudio

func _ready() -> void:
	super()
	if Global.player.stats.event_flags[IndigoRisingWaterEvent.DRAIN_WATER_EVENT_ID]:
		queue_free()
		return
	get_tree().create_timer(initial_delay).timeout.connect(shootWithoutWarn)
	
func shootWithoutWarn() -> void:
	animation.play("splash")
	sound.play_sound_effect_from_library("splash")
	await animation.animation_finished
	shoot()

func shoot() -> void:
	await get_tree().create_timer(warn_after, false).timeout
	warn_particles.emitting = true
	await get_tree().create_timer(shoot_after_warn, false).timeout
	animation.play("splash")
	sound.play_sound_effect_from_library("splash")
	await animation.animation_finished
	shoot()
