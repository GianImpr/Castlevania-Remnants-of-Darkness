extends Node
@export var dialogue_1: DialogueBoxTrigger
@export var dialogue_2: DialogueBoxTrigger
@export var trevor_npc: NPC
@export var event_id: int

func _ready() -> void:
	if Global.player.stats.event_flags[event_id]:
		trevor_npc.queue_free()
		queue_free()
		
func _process(delta: float) -> void:
	if Global.player.stats.dialogue_flags[dialogue_2.flag_id]:
		trevor_npc.turnLeft()
