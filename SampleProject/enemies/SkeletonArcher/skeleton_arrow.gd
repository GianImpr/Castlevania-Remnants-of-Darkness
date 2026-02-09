extends RigidBody2D
class_name SkeletonArrow
@export var stats: Projectile
@export var hitbox_iframe: CollisionShape2D
@export var area: Area2D
@export var sprite: Sprite2D
@export var iframes_duration: float = 1
@export var animation: AnimationPlayer
static var on_cooldown: bool = false
@export var SPEED: float
var direction: int

func _ready() -> void:
	area.body_entered.connect(_on_area_2d_body_entered)
	linear_velocity.x = SPEED*direction
	if direction == 1:
		sprite.scale *= -1

func _physics_process(delta: float) -> void:
	position = position + linear_velocity * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_hurt and not on_cooldown:
		stats.apply_damage(body, stats.calculate_damage(body))
		on_cooldown = true
		if stats.destroy_on_contact:
			destroy()
		get_tree().create_timer(iframes_duration).timeout.connect(func(): on_cooldown = false)
		call_deferred("reparent", body, true)
		linear_velocity = Vector2.ZERO
		var disappear_tween: Tween = get_tree().create_tween()
		disappear_tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2).set_delay(0.6)
		disappear_tween.finished.connect(queue_free)
		
		
	
func destroy():
	linear_velocity = Vector2.ZERO
	animation.play("destroy")
