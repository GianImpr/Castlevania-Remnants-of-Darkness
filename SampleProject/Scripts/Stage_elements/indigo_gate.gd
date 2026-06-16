extends StaticBody2D
class_name IndigoGate
static var switch_event_ids: Array[int] = [16,17]
@export var hint_id: int
const HINT_17_MESSAGE: String = "HINT_17"
static var opened: bool = false

func _ready() -> void:
	opened = false
	if checkGateIsOpen():
		queue_free()
		
func _process(delta: float) -> void:
	if opened:
		queue_free()

static func checkGateIsOpen() -> bool:
	var door_open: bool = true
	for id in switch_event_ids:
		if not Global.player.stats.event_flags[id]:
			door_open = false
			break
	
	return door_open
	
static func checkGateUnlocked() -> void:
	const MESSAGE_DURATION_SECONDS: float = 2
	if checkGateIsOpen():
		Global.tutorial_box.popup(HINT_17_MESSAGE, MESSAGE_DURATION_SECONDS)
	opened = true
