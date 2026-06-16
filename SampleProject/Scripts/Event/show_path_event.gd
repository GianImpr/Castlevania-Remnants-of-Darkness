extends Node
@export var event_id: int
const OFFSET: Vector2 = Vector2(-1050, 0)
const OFFSET_DURATION: float = 1
const SCROLLING_DURATION: float = 3

func _ready() -> void:
	if Global.player.stats.event_flags[event_id]:
		queue_free()
		
func triggerEvent(body: Node2D) -> void:
	Global.player.freeze()
	Global.camera.moveCamera(OFFSET, OFFSET_DURATION, SCROLLING_DURATION, false)
	await Global.camera.camera_moved_back
	Global.player.unfreeze()
	Global.player.stats.event_flags[event_id] = true
	queue_free()
