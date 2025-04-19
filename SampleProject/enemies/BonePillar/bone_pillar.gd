extends Enemy
var facing_position: int = -1
var activated_AI: bool = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity()*2 * delta
	move_and_slide()
		
	remove_glow_if_glowing()
