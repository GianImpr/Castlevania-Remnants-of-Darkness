extends Enemy
class_name BlackCrow

@export var vision: Area2D
var facing_position: int
var ai_activated: bool = false


func _ready() -> void:
	super()
	facing_position = -1
	
func _physics_process(delta: float) -> void:
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_hitbox_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(1, body)


func _on_hitbox_iframe_timeout() -> void:
	hitbox_iframe.set_deferred("monitoring", true)
