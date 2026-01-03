extends Node2D
class_name BigWaterSplash

@export var sprite: Sprite2D
@export var light: Light2D
@export var animation: AnimationPlayer
const MAX_MASKS: int = 8
static var cur_mask: int = 0

func _ready() -> void:
	cur_mask = posmod(cur_mask+1, MAX_MASKS)+1
	sprite.set_light_mask(cur_mask)
	light.set_item_cull_mask(cur_mask)

func bigSplash() -> void:
	animation.play("splash")
	
func smallSplash() -> void:
	animation.play("small_splash")
