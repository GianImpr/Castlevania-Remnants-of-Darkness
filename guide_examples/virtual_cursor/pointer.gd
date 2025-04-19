extends Area2D

@export var cursor_2d:GUIDEAction
@export var click:GUIDEAction


func _ready():
	click.triggered.connect(_click)

func _process(delta):
	global_position = cursor_2d.value_axis_2d


func _click():
	for clickable in get_overlapping_areas():
		if clickable.has_method("spin"):
			clickable.spin()
