extends Control

@export var label: Label
@export var animation: AnimationPlayer

func _ready() -> void:
	visible = false
	Global.stage_presentation = self
	
func play(stage_name: String):
	visible = true
	label.text = stage_name
	animation.play("present")
	
func stop():
	visible = false
