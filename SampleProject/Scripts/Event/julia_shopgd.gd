extends Node2D
class_name JuliaShop
@export var julia_sprite: Sprite2D
@export var animation: AnimationPlayer

func _process(delta: float) -> void:
	julia_sprite.flip_h = Global.player.global_position > global_position

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Global.player:
		Global.player.tap_up.appear()
		Shop.can_open = true
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == Global.player:
		Global.player.tap_up.dismiss()
		Shop.can_open = false
