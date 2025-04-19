extends Sprite2D

func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(0.212, 0.353, 1, 0), 0.5)
	await tween.finished
	queue_free()
