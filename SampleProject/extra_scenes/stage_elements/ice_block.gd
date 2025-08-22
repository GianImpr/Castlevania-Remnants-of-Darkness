extends StaticBody2D
class_name IceBlock

@export var animation: AnimationPlayer

func evaporate() -> void:
	if not animation.is_playing():
		animation.play("evaporating")
