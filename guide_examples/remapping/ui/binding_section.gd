@tool
extends MarginContainer

@onready var _label:Label = %Label

@export var text:String:
	set(value):
		text = value
		_refresh()
		
		
func _ready():
	_refresh()
		
func _refresh():
	if _label != null:
		_label.text = text
	
