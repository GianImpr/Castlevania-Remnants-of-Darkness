extends Enemy

var facing_position: int

func _ready() -> void:
	super()
	facing_position = -1
	
func _physics_process(delta: float) -> void:
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	hit_target(1, body)


func _on_hitbox_iframe_timeout() -> void:
	hitbox_iframe.set_deferred("monitoring", true)
