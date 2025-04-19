extends RigidBody2D
@export var stats: Projectile
@export var sprite: Sprite2D
@export var hitbox_iframe: CollisionShape2D
@export var animation: AnimationPlayer
@export var hurtbox: CollisionShape2D
@export var lifespan_timer: Timer
var direction: int
@export var SPEED: float
var going_back: bool = false
var hit: bool = false
var max_speed: float
var time_to_slowdown: bool = false

func _ready():
	linear_velocity.x = SPEED * direction

func _physics_process(delta: float) -> void:
	move_local_x(delta)

func calculate_damage(body, multiplier) -> int:
	return stats.calculate_damage(body, multiplier)

	
func apply_damage(body, damage):
	body.damage_popup.popup(damage, 0)
	body.stats.Stats["HP"] -= damage
	body.is_hurt = true
	
func destroy():
	linear_velocity.x = 0
	hurtbox.set_deferred("disabled", true)
	hitbox_iframe.set_deferred("disabled", true)
	animation.play("destroy")
	hit = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	var multiplier = 1
	if not body.is_hurt:
		var damage = calculate_damage(body, multiplier)
		apply_damage(body, damage)
	if stats.destroy_on_contact:
		destroy()

func _on_lifespan_timeout() -> void:
	destroy()
