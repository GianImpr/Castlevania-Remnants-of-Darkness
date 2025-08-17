extends Enemy
class_name Lizardman

var facing_position: int
@export var is_moving: bool = true
@export var contact_damage_multiplier: float = 1
@export var sword_damage_multiplier: float = 1.5
@export var sword_chip_damage: int
@export var dash_attack_damage_multiplier: float = 2
@export var dash_attack_chip_damage: int
@export var sword_hitbox: Area2D
@export var dash_attack_hitbox: Area2D

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.body_entered.connect(_on_area_2d_body_entered)
	sword_hitbox.body_entered.connect(_on_sword_2d_body_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	hit_target(contact_damage_multiplier, body, hitbox_iframe)
	
func _on_sword_2d_body_entered(body: Node2D) -> void:
	hit_target(sword_damage_multiplier, body, hitbox_iframe, sword_chip_damage, false, Global.Attribute.SLASH)

func _on_dash_attack_2d_body_entered(body: Node2D) -> void:
	hit_target(dash_attack_damage_multiplier, body, hitbox_iframe, dash_attack_chip_damage, true, Global.Attribute.SLASH)

func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)
