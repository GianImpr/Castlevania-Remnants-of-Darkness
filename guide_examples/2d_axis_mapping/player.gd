## A very simple player script for a player who can only move.
extends Node2D

@export var speed:float = 300
@export var move_action:GUIDEAction

func _process(delta:float) -> void:
	# GUIDE already gives us a full 2D axis. We don't need to build it
	# ourselves using Input.get_vector.
	position += move_action.value_axis_2d.normalized() * speed * delta
