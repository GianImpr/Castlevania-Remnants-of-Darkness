extends StaticBody2D
class_name DialogueBoxTrigger

@export var flag_id: int
static var startDialogue: Callable

func _on_area_2d_area_entered(area: Area2D) -> void:
	if Global.player.stats.dialogue_flags[flag_id]:
		queue_free()
		return
	Global.player.stats.dialogue_flags[flag_id] = true
	Global.dialogue_screen.dialogue_entries = Game.get_singleton().dialogue_compendium[flag_id-1]
	startDialogue.call()
