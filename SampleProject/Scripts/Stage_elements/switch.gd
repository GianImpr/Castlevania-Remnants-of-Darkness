extends StaticBody2D
class_name Switch

@export var event_id: int
@export var animation: AnimationPlayer

func _ready() -> void:
	if Global.player.stats.event_flags[event_id]:
		initializeAsPressed()
		
func initializeAsPressed() -> void:
	animation.play("press_instantly")


func _on_detection_body_entered(body: Node2D) -> void:
	animation.play("press")
	Global.player.stats.event_flags[event_id] = true
