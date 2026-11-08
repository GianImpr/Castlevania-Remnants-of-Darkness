@tool
extends Control

@export var object_edit: Node

@onready var name_edit: LineEdit = $Name
@onready var pick_button: Button = $PickButton

var value: String:
	set(t):
		name_edit.text = t
	get:
		return name_edit.text

func _ready() -> void:
	if is_part_of_edited_scene():
		return
	object_edit.object_changed.connect(update_button)

func update_button():
	pick_button.disabled = object_edit.object == null

func pick() -> void:
	pass

func on_picked(target: String):
	if not target.is_empty():
		value = target
