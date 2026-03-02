extends Enemy
class_name BlackPanther

var activated_AI: bool = false
var facing_position: int
@export var is_moving: bool = true
@export var vision: Area2D

func _ready() -> void:
	super()
	facing_position = -1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(1, body, hitbox_iframe)


func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.set_deferred("disabled", false)
