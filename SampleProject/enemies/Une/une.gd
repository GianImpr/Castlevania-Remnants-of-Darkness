extends Enemy
class_name Une

@export var vision: Area2D

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(1, body, hitbox_iframe)
		
func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.set_deferred("disabled", false)
