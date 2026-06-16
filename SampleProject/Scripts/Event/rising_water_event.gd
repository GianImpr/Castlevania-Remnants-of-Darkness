extends Node
class_name IndigoRisingWaterEvent

@export var gate_animation: AnimationPlayer
@export_range(1,300,1, "suffix:s") var water_rising_duration: float
@export var event_id: int
static var DRAIN_WATER_EVENT_ID: int = 19
@export var water: Water
@export var lions: Node2D
@export var player_detection_area: Area2D
const WATER_FINAL_POSITION: Vector2 = Vector2(352, 1262)
const CAMERA_OFFSET: Vector2 = Vector2(0, -1150)
const CAMERA_DURATION_SECONDS: float = 1.5
const CAMERA_SCROLLING_DURATION_SECONDS: float = 4
const FIRST_LION_LINE_INDEX: int = 1
const SECOND_LION_LINE_INDEX: int = 4
const THIRD_LION_LINE_INDEX: int = 6
var cur_lion_index: int = 0
const INITIAL_WAIT_SECONDS: float = 1.2
const ACTIVATE_SECOND_LION_LINE_AFTER_SECONDS: float = 1.5
const ACTIVATE_THIRD_LION_LINE_AFTER_SECONDS: float = 3

func _ready() -> void:
	if Global.player.stats.event_flags[event_id] and not Global.player.stats.event_flags[DRAIN_WATER_EVENT_ID]:
		gate_animation.play("close")
		for lion in lions.get_children():
			lion.activateInstantly()
		water.position = WATER_FINAL_POSITION
		queue_free()
	elif Global.player.stats.event_flags[event_id] and Global.player.stats.event_flags[DRAIN_WATER_EVENT_ID]:
		queue_free()
		

func startWaterRise() -> void:
	Global.screen = Global.ScreenType.EVENT
	Global.music_player.fadeMusic()
	Global.player.freeze()
	Global.player.can_use_magical_ticket = false
	gate_animation.play("close")
	activateLions(FIRST_LION_LINE_INDEX)
	await get_tree().create_timer(INITIAL_WAIT_SECONDS).timeout
	Global.music_player.restoreVolumeDB()
	Global.music_player.stream.resource_name = "decisive_battle"
	Global.music_player.play_sound_effect_from_library("decisive_battle")
	get_tree().create_timer(ACTIVATE_SECOND_LION_LINE_AFTER_SECONDS).timeout.connect(activateLions.bind(SECOND_LION_LINE_INDEX))
	get_tree().create_timer(ACTIVATE_THIRD_LION_LINE_AFTER_SECONDS).timeout.connect(activateLions.bind(THIRD_LION_LINE_INDEX))
	Global.camera.moveCamera(CAMERA_OFFSET, CAMERA_DURATION_SECONDS, CAMERA_SCROLLING_DURATION_SECONDS, false)
	await Global.camera.camera_moved_back
	Global.player.unfreeze()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(water, "position", WATER_FINAL_POSITION, water_rising_duration)
	Global.player.stats.event_flags[event_id] = true
	Global.screen = Global.ScreenType.NONE

func activateLions(until_index_included: int) -> void:
	while cur_lion_index <= until_index_included:
		var current_lion: LionIndigo = lions.get_child(cur_lion_index)
		current_lion.activate()
		cur_lion_index += 1


func _on_area_2d_body_entered(body: Node2D) -> void:
	startWaterRise()
	player_detection_area.set_deferred("monitoring", false)
