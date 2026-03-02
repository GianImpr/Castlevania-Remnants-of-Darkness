extends Node2D
class_name OffensiveFirePillars
@export var stats: Projectile
@export var area: Area2D
@export var iframes_duration: float = 1
static var on_cooldown: bool = false

func _ready() -> void:
	area.area_entered.connect(_on_area_2d_area_entered)

func _on_area_2d_area_entered(area_node: Area2D) -> void:
	var body = area_node.get_parent()
	if not body.is_hurt and not on_cooldown:
		stats.apply_damage(body, stats.calculate_damage(body))
		on_cooldown = true
		get_tree().create_timer(iframes_duration).timeout.connect(func(): on_cooldown = false)
