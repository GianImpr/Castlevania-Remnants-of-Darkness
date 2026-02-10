extends RigidBody2D
class_name Ink
@export var stats: Projectile
@export var area: Area2D
@export var iframes_duration: float = 1
static var on_cooldown: bool = false
@export var SPEED: Vector2

var facing_position: int = 1

func _ready() -> void:
	area.body_entered.connect(_on_area_2d_body_entered)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_hurt and not on_cooldown:
		stats.apply_damage(body, stats.calculate_damage(body))
		on_cooldown = true
		get_tree().create_timer(iframes_duration).timeout.connect(func(): on_cooldown = false)
	
