extends Node2D
class_name SwordShredder
@export var sprite: Sprite2D
@export var animation: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = Global.player.sprite.weapon.texture
	if Global.player.facing_position == -1:
		sprite.scale.x *= -1
		animation.play("spin_reverse")
