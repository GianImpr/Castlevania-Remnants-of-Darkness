extends Node2D
class_name JuliaShop
@export var julia_sprite: Sprite2D
@export var animation: AnimationPlayer

func _process(delta: float) -> void:
	julia_sprite.flip_h = Global.player.global_position > global_position

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area == Global.player:
		Global.player.tap_up.appear()
		Shop.can_open = true
	
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area == Global.player:
		Global.player.tap_up.dismiss()
		Shop.can_open = false
