extends Node
@export var dialogue: DialogueBoxTrigger
@export var trevor_npc: NPC
@export var julia_npc: JuliaShop
const WAIT_TIME_SECONDS: float = 0.5
const DIALOGUE_ID_JULIA_SHOWS_STONE: int = 45
const DIALOGUE_ID_JULIA_HIDES_STONE: int = 69
const DIALOGUE_ID_TREVOR_DEPARTS: int = 96

func _ready() -> void:
	if not Global.dialogue_screen.entry_changed.is_connected(checkDialogue):
		Global.dialogue_screen.entry_changed.connect(checkDialogue)
		Global.dialogue_screen.dialogue_ended.connect(deleteEventIfDone)
	deleteEventIfDone()
	
func checkDialogue(cur_dialogue_entry: int) -> void:
	match cur_dialogue_entry:
		DIALOGUE_ID_JULIA_SHOWS_STONE:
			juliaShowsStone()
		DIALOGUE_ID_JULIA_HIDES_STONE:
			juliaHidesStone()
		DIALOGUE_ID_TREVOR_DEPARTS:
			trevorDeparts()

func juliaShowsStone() -> void:
	julia_npc.animation.play("show_stone")
	
func juliaHidesStone() -> void:
	julia_npc.animation.play_backwards("show_stone")

func trevorDeparts() -> void:
	await Global.total_fade_screen.fadeOutFor(WAIT_TIME_SECONDS)
	trevor_npc.visible = false
	await get_tree().create_timer(WAIT_TIME_SECONDS).timeout
	await Global.total_fade_screen.fadeInFor(WAIT_TIME_SECONDS)
	
func deleteEventIfDone() -> void:
	if Global.player.stats.dialogue_flags[dialogue.flag_id]:
		queue_free()
