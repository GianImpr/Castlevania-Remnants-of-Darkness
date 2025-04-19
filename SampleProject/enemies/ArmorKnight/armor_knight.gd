extends Enemy
@export var vision: Area2D
@export var spear: Area2D
@export var special: Area2D
@export var vertical_spear_hitbox: Area2D
var activated_AI: bool = false
var facing_position: int = -1
var deflect_projectile: bool = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()


func _on_detection_body_entered(body: Node2D) -> void:
	hit_target(1, body)
	

func _on_spear_body_entered(body: Node2D) -> void:
	hit_target(1.5, body, spear)
	

func _on_special_body_entered(body: Node2D) -> void:
	hit_target(3, body, special, 10, true)


func _on_spear_up_down_body_entered(body: Node2D) -> void:
	hit_target(1.5, body, vertical_spear_hitbox, 4)

func _on_detect_projectiles_area_entered(area: Area2D) -> void:
	if area.get_parent() is Icicle:
		deflect_projectile = true


func _on_protective_swing_area_entered(area: Area2D) -> void:
	if area.get_parent() is Icicle:
		area.get_parent().destroy()
