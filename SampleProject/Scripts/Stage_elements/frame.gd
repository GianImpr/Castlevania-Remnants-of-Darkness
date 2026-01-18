extends Node2D
class_name TrainingFrame

var inside_area: bool = false
@export var animation: AnimationPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up_arrow") and inside_area and Global.screen == Global.ScreenType.NONE:
		var old_anim_pos: float = animation.current_animation_position
		animation.play("activate")
		Global.player.freeze()
		await animation.animation_finished
		Global.training_menu.openMenu()
		await get_tree().create_timer(1).timeout
		animation.play("RESET")
		await get_tree().create_timer(0.1).timeout
		animation.play("idle")
		animation.seek(old_anim_pos)

		

func _on_area_2d_body_entered(body: Node2D) -> void:
	inside_area = true
	Global.player.tap_up.appear()


func _on_area_2d_body_exited(body: Node2D) -> void:
	inside_area = false
	if Global.player:
		Global.player.tap_up.dismiss()
