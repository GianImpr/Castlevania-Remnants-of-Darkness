extends Sprite2D
class_name TapUp

func _ready() -> void:
	self_modulate = Color(1,1,1,0)

func appear(down_arrow: bool = false) -> void:
	flip_v = down_arrow
	self_modulate = Color(1,1,1,0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate", Color(1,1,1,1), 0.2)
	
func dismiss() -> void:
	self_modulate = Color(1,1,1,1)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "self_modulate", Color(1,1,1,0), 0.2)
