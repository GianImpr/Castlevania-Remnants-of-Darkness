## Base class for icon renderers. Note that all icon renderers must be tool
## scripts.
@tool
class_name GUIDEIconRenderer
extends Control

## The priority of this icon renderer. Built-in renderers use priority 0. Built-in
## fallback renderer uses priority 100. The smaller the number the higher the priority.
@export var priority:int = 0

## Whether or not this renderer can render an icon for this input.
func supports(input:GUIDEInput) -> bool:
	return false
	
## Set up the scene so that the given input can be rendered. This will
## only be called for input where `supports` has returned true.
func render(input:GUIDEInput) -> void:
	pass
 

## A cache key for the given input. This should be unique for this renderer
## and the given input. The same input should yield the same cache key for
## each renderer.
func cache_key(input:GUIDEInput) -> String:
	push_error("Custom renderers must override the cache_key function to ensure proper caching.")
	return "i-forgot-the-cache-key"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

