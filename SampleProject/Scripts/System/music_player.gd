extends PolyphonicMenuAudio

func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = custom_max_polyphony
	Global.music_player = self
