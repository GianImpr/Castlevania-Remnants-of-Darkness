extends Node2D

@export var starting_context:GUIDEMappingContext

func _ready():
	GUIDE.enable_mapping_context(starting_context)
