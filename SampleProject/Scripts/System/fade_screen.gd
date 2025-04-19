extends TextureRect
@export var animation: AnimationPlayer

func _ready() -> void:
	Global.fade_screen = self
