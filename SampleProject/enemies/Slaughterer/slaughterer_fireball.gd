extends RigidBody2D
class_name SlaughtererFireball
@export var stats: Projectile
@export var area: Area2D
@export var sprite: Sprite2D
@export var iframes_duration: float = 1
@export var animation: AnimationPlayer
@export var raycast: RayCast2D
static var on_cooldown: bool = false
@export var SPEED: Vector2

var MAX_VERTICAL_SPEED: float = SPEED.y
var facing_position: int = 1

const MAX_SPEED_ANGLE: float = deg_to_rad(45)
const MIN_SPEED_ANGLE: float = deg_to_rad(-45)
const LERP_WEIGHT_OFFSET: float = 0.5

func _ready() -> void:
	area.area_entered.connect(_on_area_2d_area_entered)
	MAX_VERTICAL_SPEED = SPEED.y
	sprite.scale.x *= facing_position * (-1)
	linear_velocity = SPEED
	
func _physics_process(delta: float) -> void:
	var result = rad_to_deg(lerp_angle(MIN_SPEED_ANGLE, MAX_SPEED_ANGLE, (linear_velocity.y/MAX_VERTICAL_SPEED)+LERP_WEIGHT_OFFSET)) * facing_position * (-1)
	sprite.rotation_degrees = clampf(result, rad_to_deg(MIN_SPEED_ANGLE), rad_to_deg(MAX_SPEED_ANGLE))
	position = position + linear_velocity * delta
	if raycast.is_colliding() and raycast.get_collider() is TileMapLayer and linear_velocity.y > 0:
		destroy()



func _on_area_2d_area_entered(area_node: Area2D) -> void:
	var body = area_node.get_parent()
	if not body.is_hurt and not on_cooldown:
		stats.apply_damage(body, stats.calculate_damage(body))
		on_cooldown = true
		if stats.destroy_on_contact:
			destroy()
		get_tree().create_timer(iframes_duration).timeout.connect(func(): on_cooldown = false)
	
func destroy():
	animation.play("destroy")
