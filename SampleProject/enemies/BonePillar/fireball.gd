extends RigidBody2D
@export var stats: Projectile
@export var sprite: Sprite2D
@export var hitbox_iframe: CollisionShape2D
@export var animation: AnimationPlayer
@export var hurtbox: CollisionShape2D
@export var lifespan_timer: Timer
@export var knockback: bool = false
@export var align_velocity_to_angle: bool = false
var direction: int
@export var SPEED: float
var going_back: bool = false
var hit: bool = false
var max_speed: float
var time_to_slowdown: bool = false

func _ready():
	linear_velocity.x = SPEED * direction
	
func _physics_process(delta: float) -> void:
	if not align_velocity_to_angle:
		move_local_x(delta)
	else:
		move_and_collide(linear_velocity*delta)

func calculate_damage(body, multiplier) -> int:
	return stats.calculate_damage(body, multiplier, knockback)

	
func apply_damage(body, damage):
	stats.apply_damage(body, damage)
	
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
	
func applyDegreeVelocity() -> void:
	linear_velocity.x = SPEED * direction * cos(rotation)
	linear_velocity.y = SPEED * sin(rotation) * direction


func _on_body_entered(body: Node) -> void:
	pass # Replace with function body.
