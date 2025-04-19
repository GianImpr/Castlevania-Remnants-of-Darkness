extends RichTextLabel

func _ready() -> void:
	Global.fps_display = self

func _process(delta: float) -> void:
	var elapsed_frames: float = Engine.get_frames_per_second()
	if elapsed_frames < ProjectSettings.get_setting("application/run/max_fps"):
		text = "[color=#ffff00]" + str(elapsed_frames) + " FPS[/color]"
	else:
		text = str(elapsed_frames) + " FPS"
