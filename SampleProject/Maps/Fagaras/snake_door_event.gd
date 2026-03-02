extends StaticBody2D
class_name SnakeDoorEvent

@export var event_flag: int
@export var hint_14: HintBoxTrigger
@export var hint_15: HintBoxTrigger

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.player.stats.event_flags[event_flag]:
		queue_free()
	elif not hasEyes():
		hint_15.queue_free()
	elif hasEyes():
		hint_14.queue_free()
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	if hasEyes():
		Global.player.stats.event_flags[event_flag] = true
		queue_free()

func hasEyes() -> bool:
	return Global.player.stats.findItem(Item.Items.LEFT_SERPENT_EYE+1, Global.player.stats.item_inventory) \
		   and Global.player.stats.findItem(Item.Items.RIGHT_SERPENT_EYE+1, Global.player.stats.item_inventory)
