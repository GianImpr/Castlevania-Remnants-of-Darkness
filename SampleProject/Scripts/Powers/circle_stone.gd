extends RigidBody2D
class_name CircleStone
@export var stats: Projectile
@export var area: Area2D
@export var sprite: Sprite2D
@export var iframes_duration: float = 1
@export var animation: AnimationPlayer
@export var raycast: RayCast2D
@export var hurtbox: CollisionShape2D
var hitbox_iframe: CollisionShape2D
static var on_cooldown: bool = false

func _ready() -> void:
	hitbox_iframe = hurtbox
	area.body_entered.connect(_on_area_2d_body_entered)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_hurt and not on_cooldown:
		stats.apply_damage(body, stats.calculate_damage(body))
		on_cooldown = true
		if stats.destroy_on_contact and not hurtbox.disabled:
			destroy()
		get_tree().create_timer(iframes_duration).timeout.connect(func(): on_cooldown = false)
	
func destroy():
	animation.play("destroy")
	area.set_deferred("monitoring", false)
