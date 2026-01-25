extends PolyphonicMenuAudio
class_name MusicPlayer
const SILENT_DB: float = -80
const DEFAULT_VOLUME_DB: float = -15

func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = custom_max_polyphony
	Global.music_player = self
	
func restoreVolumeDB() -> void:
	volume_db = DEFAULT_VOLUME_DB

func fadeMusic(duration: float = 1) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "volume_db", SILENT_DB, duration)
	await tween.finished
	stop()
