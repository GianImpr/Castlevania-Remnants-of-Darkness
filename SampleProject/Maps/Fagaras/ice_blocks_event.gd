extends Node
class_name IceBlocks

const ICE_BLOCKS: int = 5
@export var event_flag: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.player.stats.event_flags[event_flag]:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_child_count() < ICE_BLOCKS:
		Global.player.stats.event_flags[event_flag] = true
