extends Enemy
class_name Ukoback

var facing_position: int = -1
@export var is_moving: bool = true
@export var canister_shape: Area2D
@export var contact_damage_multiplier: float = 1
@export var canister_contact_damage_multiplier: float = 2
@export var raycast_up: RayCast2D
@export var raycast_down: RayCast2D
@export var flame_projectile_scene: PackedScene
var moving_up: bool = false

var hits_taken: int = 1 #Start at 1 only to guarantee knockback on first hit
const HIT_KNOCKBACK_THRESHOLD: int = 2

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.body_entered.connect(_on_area_2d_body_entered)
	canister_shape.body_entered.connect(_on_canister_body_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	hit_target(contact_damage_multiplier, body, hitbox_iframe)
	
func _on_canister_body_entered(body: Node2D) -> void:
	hit_target(canister_contact_damage_multiplier, body, canister_shape, 0, false, Global.Attribute.FIRE)


func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)
