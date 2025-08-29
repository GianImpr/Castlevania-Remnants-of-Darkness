extends BreakableWall
class_name HectorStatue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().create_timer(0.05).timeout.connect(wall.detonate)
	sound.play_sound_effect_from_library("break")
