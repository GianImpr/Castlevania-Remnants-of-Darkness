extends Enemy


@export var vision: Area2D
var activated_AI: bool = false
var facing_position: int

func _ready() -> void:
	super()
	facing_position = -1
	direction = -1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()
	

	
func _on_area_2d_body_entered(body: Node2D) -> void:
	hit_target(1, body, hitbox_iframe)


func _on_timer_timeout() -> void:
	hitbox_iframe.set_deferred("monitoring", true)
