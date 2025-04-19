extends Enemy
var activated_AI: bool = false
var facing_position: int
@export var is_moving: bool = true
@export var vision: Area2D

func _ready() -> void:
	super()
	facing_position = -1

func _physics_process(delta: float) -> void:
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	hit_target(1, body, hitbox_iframe)
		
func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.set_deferred("disabled", false)
