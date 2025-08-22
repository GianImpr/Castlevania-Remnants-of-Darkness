extends Node
class_name AguniLaurelSpawner

@export var particles: GPUParticles2D
@export var aguni_laurel_pickup: PickUp
@export var event_flag: int
@export var aguni_laurel_position: Vector2
@export var sound: PolyphonicAudio
@export var bird_spawn: SpawnEnemy

var triggered_candles: int = 0
const CANDLES_TO_BE_TRIGGERED: int = 3
const AGUNI_SPAWN_DELAY: float = 0.5
const BIRD_STOP_SPAWN_OFFSET: float = 200


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Global.player.stats.findItem(Relic.Relics.AGUNIS_LAUREL+1, Global.player.stats.relic_inventory) and Global.player.stats.event_flags[event_flag]:
		spawnAguniLaurel()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.player.global_position.y > bird_spawn.position.y + BIRD_STOP_SPAWN_OFFSET:
		bird_spawn.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		bird_spawn.process_mode = Node.PROCESS_MODE_INHERIT
		
	triggered_candles = 0
	for child in get_children():
		if child is AguniAirCandle:
			if child.triggered:
				triggered_candles += 1
				
	if triggered_candles == CANDLES_TO_BE_TRIGGERED and not Global.player.stats.event_flags[event_flag]:
		spawnAguniLaurel()
		
func spawnAguniLaurel() -> void:
	particles.emitting = true
	sound.play_sound_effect_from_library("activate")
	Global.player.stats.event_flags[event_flag] = true
	get_tree().create_timer(AGUNI_SPAWN_DELAY).timeout.connect(func(): aguni_laurel_pickup.global_position = aguni_laurel_position)
