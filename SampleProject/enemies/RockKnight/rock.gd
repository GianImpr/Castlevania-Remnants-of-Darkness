extends RigidBody2D
class_name Rock
@export var stats: Projectile
@export var area: Area2D
@export var sprite: Sprite2D
@export var iframes_duration: float = 1
@export var animation: AnimationPlayer
@export var raycast: RayCast2D
static var on_cooldown: bool = false
@export var SPEED: Vector2
@export var rock_shatter_scene: PackedScene

var MAX_VERTICAL_SPEED: float = SPEED.y
var facing_position: int = 1

func _ready() -> void:
	area.body_entered.connect(_on_area_2d_body_entered)
	MAX_VERTICAL_SPEED = SPEED.y
	linear_velocity = SPEED
	if facing_position == 1:
		sprite.scale.x *= -1
	
func _physics_process(delta: float) -> void:
	position = position + linear_velocity * delta
	if raycast.is_colliding() and raycast.get_collider() is TileMapLayer and linear_velocity.y > 0:
		destroy()



func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_hurt and not on_cooldown:
		stats.apply_damage(body, stats.calculate_damage(body))
		on_cooldown = true
		if stats.destroy_on_contact:
			destroy()
		get_tree().create_timer(iframes_duration).timeout.connect(func(): on_cooldown = false)
	
func destroy():
	linear_velocity = Vector2.ZERO
	animation.play("destroy")


func rockShatter() -> void:
	var rock_shatter = rock_shatter_scene.instantiate()
	rock_shatter.global_position = global_position
	rock_shatter.facing_position = facing_position*(-1)
	if facing_position == 1:
		rock_shatter.turnAround()
	MetSys.get_current_room_instance().add_child(rock_shatter)
