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
	area.area_entered.connect(_on_area_2d_area_entered)

func _on_area_2d_area_entered(area_node: Area2D) -> void:
	var body = area_node.get_parent()
	if not body.is_hurt and not on_cooldown:
		stats.apply_damage(body, stats.calculate_damage(body))
		on_cooldown = true
		if stats.destroy_on_contact and not hurtbox.disabled:
			destroy()
		get_tree().create_timer(iframes_duration).timeout.connect(func(): on_cooldown = false)
	
func destroy():
	animation.play("destroy")
	area.set_deferred("monitoring", false)
