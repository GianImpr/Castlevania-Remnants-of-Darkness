@icon("res://addons/guide/guide_internal.svg")
@tool
## An action to input mapping
class_name GUIDEActionMapping
extends Resource

## The action to be mapped
@export var action:GUIDEAction:
	set(value):
		if value == action:
			return
		action = value
		emit_changed()

## A set of input mappings that can trigger the action
@export var input_mappings:Array[GUIDEInputMapping] = []:
	set(value):
		if value == input_mappings:
			return
		input_mappings = value
		emit_changed()		
