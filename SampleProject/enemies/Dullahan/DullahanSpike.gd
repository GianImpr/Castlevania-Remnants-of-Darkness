extends Node2D
class_name DullahanSpikes
@export var stats: Projectile
@export var area: Area2D
@export var iframes: Timer
static var on_cooldown: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_hurt and not on_cooldown:
		stats.apply_damage(body, stats.calculate_damage(body))
		on_cooldown = true
		iframes.start()

func _on_iframe_timer_timeout() -> void:
	on_cooldown = false
