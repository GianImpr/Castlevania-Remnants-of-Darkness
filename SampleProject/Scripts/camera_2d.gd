extends Camera2D
class_name GameCamera
@export var random_strength: float = 10.0
@export var shake_fade: float = 5.0

const DEFAULT_RANDOM_STRENGTH: float = 10.0
var shake_strength: float = 0.0
signal camera_moved
signal camera_moved_back

func _ready() -> void:
	Global.camera = self
	
func apply_shake():
	shake_strength = random_strength

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		
		offset = _randomOffset()
		
func _randomOffset() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

## Moves the camera in the specified offset position.
## Automatically moves back after a specified amount of time.
func moveCamera(to_offset: Vector2, duration: float) -> void:
	var moving_tween: Tween = get_tree().create_tween()
	const MOVE_DURATION: float = 0.5
	moving_tween.set_trans(Tween.TRANS_SINE)
	moving_tween.set_ease(Tween.EASE_IN_OUT)
	moving_tween.tween_property(self, "offset", to_offset, MOVE_DURATION)
	await moving_tween.finished
	camera_moved.emit()
	await get_tree().create_timer(duration).timeout
	moving_tween = get_tree().create_tween()
	moving_tween.set_trans(Tween.TRANS_SINE)
	moving_tween.set_ease(Tween.EASE_IN_OUT)
	moving_tween.tween_property(self, "offset", Vector2.ZERO, MOVE_DURATION)
	await moving_tween.finished
	camera_moved_back.emit()
