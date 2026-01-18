extends Node2D
class_name TrainingFrame

var inside_area: bool = false
@export var animation: AnimationPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up_arrow") and inside_area:
		animation.play("activate")
		Global.training_menu.openMenu()

func _on_area_2d_body_entered(body: Node2D) -> void:
	inside_area = true
	Global.player.tap_up.appear()


func _on_area_2d_body_exited(body: Node2D) -> void:
	inside_area = false
	Global.player.tap_up.dismiss()
