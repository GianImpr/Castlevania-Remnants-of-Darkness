extends StaticBody2D
class_name ChangeArea
@export var area: Area2D
@export var new_room_path: String
@export var new_initial_position: Vector2
@export var presentation_duration: Timer

func _on_area_2d_body_entered(body: Node2D) -> void:
	Global.change_area.emit(new_room_path, new_initial_position)
	
func _on_timer_timeout() -> void:
	area.monitoring = true
