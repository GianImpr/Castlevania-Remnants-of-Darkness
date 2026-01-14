extends FadeScreen
class_name TotalFadeScreen

func _ready() -> void:
	Global.total_fade_screen = self

func fadeOutFor(seconds: float) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "self_modulate", Color.WHITE, seconds/2)
	await tween.finished

func fadeInFor(seconds: float) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "self_modulate", Color.TRANSPARENT, seconds/2)
	await tween.finished
