extends Node
@export var dialogue_1: DialogueBoxTrigger
@export var dialogue_2: DialogueBoxTrigger
@export var trevor_npc: NPC
@export var event_id: int
const WAIT_TIME_SECONDS: float = 0.5

func _ready() -> void:
	if Global.player.stats.event_flags[event_id]:
		queue_free()
		
func _process(delta: float) -> void:
	if dialogue_2 != null and Global.player.stats.dialogue_flags[dialogue_2.flag_id]:
		trevor_npc.turnLeft()

func _on_dialogue_box_trigger_2_tree_exited() -> void:
	if Global.player.stats.event_flags[event_id]:
		return
	Global.player.freeze()
	await Global.total_fade_screen.fadeOutFor(WAIT_TIME_SECONDS)
	trevor_npc.visible = false
	await get_tree().create_timer(WAIT_TIME_SECONDS).timeout
	await Global.total_fade_screen.fadeInFor(WAIT_TIME_SECONDS)
	Global.player.unfreeze()
	Global.player.stats.event_flags[event_id] = true
	
