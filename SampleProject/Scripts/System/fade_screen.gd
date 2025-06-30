extends TextureRect
class_name FadeScreen
@export var animation: AnimationPlayer

func _ready() -> void:
	Global.fade_screen = self
