extends Sprite2D
@export var duration: float = 0.5

func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(0.5,0.5,0.5, 0), duration)
	await tween.finished
	queue_free()
