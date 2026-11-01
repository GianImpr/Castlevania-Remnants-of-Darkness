extends Node2D
@export var flash_1: Sprite2D
@export var flash_2: Sprite2D
@export var animation: AnimationPlayer
const MAX_ANGLE: float = 75.0
const MIN_ANGLE_DIFFERENCE: float = 30

func _ready() -> void:
	z_index = 15
	flash_1.rotation_degrees = randf_range(0, MAX_ANGLE)
	flash_2.rotation_degrees = randf_range(0, MAX_ANGLE)
	while abs(flash_1.rotation_degrees - flash_2.rotation_degrees) < MIN_ANGLE_DIFFERENCE:
		flash_1.rotation_degrees = randf_range(0, MAX_ANGLE)
		flash_2.rotation_degrees = randf_range(0, MAX_ANGLE)
