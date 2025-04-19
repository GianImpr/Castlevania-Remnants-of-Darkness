extends RigidBody2D
@export var SPEED: float
@export var stats: Projectile
@export var sprite: Sprite2D

func _ready() -> void:
	pass
	
func adjustFlyingDirection() -> void:
	linear_velocity = Vector2(SPEED * sin(sprite.rotation_degrees/360*PI*2) * (-1), SPEED * cos(sprite.rotation_degrees/360*PI*2))

func _physics_process(delta: float) -> void:
	move_and_collide(linear_velocity*delta)


func _on_lifetime_timeout() -> void:
	destroy()

func destroy():
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_hurt:
		stats.apply_damage(body, stats.calculate_damage(body))
	if stats.destroy_on_contact:
		destroy()
