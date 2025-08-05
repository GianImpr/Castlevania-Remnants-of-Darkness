extends Enemy
class_name SpittleBone

var facing_position: int = -1
@export var is_moving: bool = true
@export var contact_damage_multiplier: float = 1

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.body_entered.connect(_on_area_2d_body_entered)

func _physics_process(delta: float) -> void:
	remove_glow_if_glowing()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	hit_target(contact_damage_multiplier, body, hitbox_iframe)


func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)
