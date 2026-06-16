extends StaticBody2D
class_name Switch

@export var event_id: int
@export var animation: AnimationPlayer
@export var is_gate_related: bool = true
const HINT_19_MESSAGE: String = "HINT_19"
const MESSAGE_DURATION_SECONDS: float = 3

func _ready() -> void:
	if Global.player.stats.event_flags[event_id]:
		initializeAsPressed()
		
func initializeAsPressed() -> void:
	animation.play("press_instantly")


func _on_detection_body_entered(body: Node2D) -> void:
	animation.play("press")
	Global.player.stats.event_flags[event_id] = true
	if is_gate_related:
		IndigoGate.checkGateUnlocked()
	else:
		Global.tutorial_box.popup(HINT_19_MESSAGE, MESSAGE_DURATION_SECONDS)
