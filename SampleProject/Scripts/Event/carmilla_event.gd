extends Node
class_name CarmillaEvent
@export var event_flag: int
@export var carmilla_npc: Sprite2D
var dialogue_started: bool
var carmilla_animation: AnimationPlayer
var done: bool = false
var music_tween: Tween

const CARMILLA_ANIMATION_PLAYER_INDEX: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_started = false
	if Global.player.stats.dialogue_flags[event_flag]:
		queue_free()
	carmilla_animation = carmilla_npc.get_child(CARMILLA_ANIMATION_PLAYER_INDEX)
		
func _process(delta: float) -> void:
	if dialogue_started and not DialogueBox.active and not done:
		done = true
		Global.player.freeze()
		fadeMusic()
		carmilla_animation.play("warp_away")
		await carmilla_animation.animation_finished
		Global.player.unfreeze()
		playMusic("cave")
		queue_free()

func _startEvent() -> void:
	Global.player.freeze()
	Global.screen = Global.ScreenType.EVENT
	fadeMusic()
	carmilla_animation.play("warp")
	await carmilla_animation.animation_finished
	playMusic("confrontation")
	Global.player.stats.dialogue_flags[event_flag] = true
	Global.dialogue_screen.dialogue_entries = Game.get_singleton().dialogue_compendium[event_flag-1]
	dialogue_started = true
	DialogueBoxTrigger.startDialogue.call()

func _on_event_trigger_body_entered(body: Node2D) -> void:
	_startEvent()

func fadeMusic() -> void:
	const NO_VOLUME: int = -80
	const DURATION: int = 1
	music_tween = get_tree().create_tween()
	music_tween.tween_property(Global.music_player, "volume_db", NO_VOLUME, DURATION)

func playMusic(music_name: String) -> void:
	const DEFAULT_VOLUME: int = -15
	if music_tween != null and music_tween.is_running():
		music_tween.kill()
	Global.music_player.stop()
	Global.music_player.volume_db = DEFAULT_VOLUME
	Global.music_player.play_sound_effect_from_library(music_name)
