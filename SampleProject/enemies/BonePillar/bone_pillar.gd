extends Enemy
var facing_position: int = -1
var activated_AI: bool = false
@export var vision: Area2D
@export var vision_startup_timer: Timer

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity()*2 * delta
	move_and_slide()
		
	remove_glow_if_glowing()

# This avoids bone pillars from activating their AI instantly when entering the room
func _on_timer_timeout() -> void:
	vision.monitoring = true
