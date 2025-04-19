## This is the player script. Note how we can use the same script for both
## players, by just injecting different actions into them. No needs to check
## which player input we should consume.
extends Node2D

@export var speed:float = 150

@export var move_action:GUIDEAction

func _process(delta:float) -> void:
	position += move_action.value_axis_2d.normalized() * speed * delta

