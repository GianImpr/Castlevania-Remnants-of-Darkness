## Use this special reference rect to manual mark the boundaries of your 2d level
## Then check the option to use this for the level boundary rather than calculating it
## When to use this:
##  1. If the boundary calculation takes too long
##  2. The boundary calculation is incorrect
##  3. You don't want everything in the level in the levelshot image
##  4. You want more than one image from a single level (just add more boundary nodes)

@tool
class_name LevelshotBoundary
extends ReferenceRect

@export_storage var _first_run := true


func _ready() -> void:
	if !_first_run: return
	_first_run = false
	border_color = Color.YELLOW
	border_width = 4
