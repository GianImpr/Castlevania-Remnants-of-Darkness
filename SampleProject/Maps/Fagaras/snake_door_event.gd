extends StaticBody2D
class_name SnakeDoorEvent

@export var event_flag: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.player.stats.event_flags[event_flag]:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if Global.player.stats.findItem(Item.Items.POTION, Global.player.stats.item_inventory):
		pass
