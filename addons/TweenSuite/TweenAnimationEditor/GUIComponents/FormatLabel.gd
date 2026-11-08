@tool
extends Label

var original_text: String

func _ready() -> void:
	original_text = text

func format(f: Variant):
	text = original_text % f
