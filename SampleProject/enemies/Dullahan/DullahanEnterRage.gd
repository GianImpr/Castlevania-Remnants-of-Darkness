extends State
class_name DullahanEnterRage
var phase: int = 0
@export var rage_particles: CPUParticles2D
@export var rage_spark: PointLight2D
@export var rage_delay: Timer
@export var dullahan_sprite: Sprite2D

func enter():
	animation.play("teleport_center")
	player.stats.DEF += 100
	
func exit():
	player.stats.DEF -= 100
	
func Update(delta: float):
	if not animation.is_playing() and phase == 0:
		animation.play("throw_head")
		await animation.animation_finished
		phase = 1
		enableRage()
		
	if not animation.is_playing() and phase == 1 and rage_delay.is_stopped():
		rage_delay.start()
		
	if phase == 2 and not animation.is_playing():
		Transitioned.emit(self, "idle")
		

func warpToCenter() -> void:
	player.global_position.x = 480
	
func enableRage() -> void:
	player.stats.ATK *= 1.2
	dullahan_sprite.material.set_shader_parameter("enabled", true)
	sound.play_sound_effect_from_library("power_up")
	var tween = get_tree().create_tween()
	tween.tween_property(rage_spark, "energy", 9, 1)
	await tween.finished
	tween = get_tree().create_tween()
	tween.tween_property(rage_spark, "energy", 0, 1)
	rage_particles.emitting = true


func _on_rage_delay_timeout() -> void:
	animation.play_backwards("catch_head")
	phase = 2
