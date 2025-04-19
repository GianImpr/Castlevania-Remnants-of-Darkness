extends Camera2D

@export var random_strength: float = 10.0
@export var shake_fade: float = 5.0

var shake_strength: float = 0.0

func _ready() -> void:
	Global.camera = self
	
func apply_shake():
	shake_strength = random_strength

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		
		offset = randomOffset()
		
func randomOffset() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
