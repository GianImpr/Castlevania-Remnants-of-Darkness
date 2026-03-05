extends Node2D
class_name JuliaShop
@export var julia_sprite: Sprite2D
@export var animation: AnimationPlayer
const DEFAULT_FRAME: int = 2

func _process(delta: float) -> void:
	julia_sprite.flip_h = Global.player.global_position > global_position
	
	if julia_sprite.frame != DEFAULT_FRAME and Global.screen != Global.ScreenType.EVENT:
		animation.play("RESET")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area == Global.player.hurtbox_area:
		Global.player.tap_up.appear()
		Shop.can_open = true
	
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area == Global.player.hurtbox_area:
		Global.player.tap_up.dismiss()
		Shop.can_open = false
