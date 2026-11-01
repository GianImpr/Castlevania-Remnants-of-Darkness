extends Node2D
class_name SwordShredder
@export var sprite: Sprite2D
@export var animation: AnimationPlayer
const SHREDDER_SPAWNING_OFFSET: Vector2 = Vector2(45,-5)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = Global.player.sprite.weapon.texture
	if Global.player.facing_position == -1:
		sprite.scale.x *= -1
		animation.play("spin_reverse")

func _process(delta: float) -> void:
	global_position = Global.player.global_position
	global_position.x += (SHREDDER_SPAWNING_OFFSET.x * Global.player.facing_position)
	global_position.y += SHREDDER_SPAWNING_OFFSET.y
