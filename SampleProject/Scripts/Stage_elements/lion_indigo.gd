extends Node2D
class_name LionIndigo

@export var animation: AnimationPlayer

func activate() -> void:
	animation.play("activate")

func activateInstantly() -> void:
	animation.play("glowing")
