extends StaticBody2D
class_name HintBoxTrigger

@export var flag_id: int
@export_multiline var text: String
@export var time: float
@export var hint_box_scene: PackedScene
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if Global.player.stats.hint_flags[flag_id]:
		queue_free()
		return
	Global.tutorial_box.activate = true
	Global.tutorial_box.time = time
	Global.tutorial_box.text = text
	Global.player.stats.hint_flags[flag_id] = true
