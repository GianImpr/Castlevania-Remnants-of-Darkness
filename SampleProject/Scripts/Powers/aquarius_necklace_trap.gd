extends Node2D
class_name AquariusNecklaceTrap
@export var hitbox: CollisionShape2D
@export var bubbles: CPUParticles2D
@export var explosion_bubbles: CPUParticles2D
@export var sound: PolyphonicAudio
@export var detection: Area2D
const MAX_AT_ONCE: int = 2
static var traps: Array[AquariusNecklaceTrap]
const REPEAT_SOUND_AFTER_SECONDS: float = 0.1
const HITBOX_DURATION_SECONDS: float = 0.9
const REPEAT_SOUND_TIMES: int = 9
var sound_played_times: int = 0

func _ready() -> void:
	traps.append(self)
	sound.play_sound_effect_from_library("bubble")
	var number: int = traps.size()
	if number > MAX_AT_ONCE:
		var oldest_trap: AquariusNecklaceTrap = traps[0]
		traps.erase(traps[0])
		oldest_trap.detonate()

func detonate() -> void:
	sound.play_sound_effect_from_library("bubble")
	get_tree().create_timer(REPEAT_SOUND_AFTER_SECONDS, false).timeout.connect(repeatSound)
	bubbles.emitting = false
	explosion_bubbles.emitting = true
	hitbox.set_deferred("disabled", false)
	get_tree().create_timer(HITBOX_DURATION_SECONDS, false).timeout.connect(hitbox.set_deferred.bind("disabled", true))
	await explosion_bubbles.finished
	queue_free()

func repeatSound() -> void:
	sound_played_times += 1
	sound.play_sound_effect_from_library("bubble")
	if sound_played_times < REPEAT_SOUND_TIMES:
		get_tree().create_timer(REPEAT_SOUND_AFTER_SECONDS).timeout.connect(repeatSound)


func _on_detect_enemy_body_entered(body: Node2D) -> void:
	if body is not Enemy and body is not Zombie:
		return
	
	if body.stats.HP <= 0:
		return
		
	detection.set_deferred("monitoring", false)
	traps.erase(self)
	detonate()
