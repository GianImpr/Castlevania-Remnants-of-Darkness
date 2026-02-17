extends Enemy
class_name Lizardman

var facing_position: int
var is_guarding: bool = false
var should_guard: bool = false
var activated_AI: bool = false
@export var is_moving: bool = true
@export var vision: Area2D
@export var contact_damage_multiplier: float = 1
@export var sword_damage_multiplier: float = 1.5
@export var sword_chip_damage: int
@export var dash_attack_damage_multiplier: float = 2
@export var dash_attack_chip_damage: int
@export var poison_attack_damage_multiplier: float = 2
@export var poison_attack_chip_damage: int
@export var sword_hitbox: Area2D
@export var poison_hitbox: Area2D
@export var protective_area: Area2D
var dash_attacking: bool = false

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.body_entered.connect(_on_area_2d_body_entered)
	sword_hitbox.body_entered.connect(_on_sword_2d_body_entered)
	poison_hitbox.body_entered.connect(_on_poison_attack_2d_body_entered)
	protective_area.area_entered.connect(func(): should_guard = true)
	vision.body_entered.connect(_on_vision_body_entered)
	

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	hit_target(contact_damage_multiplier, body, hitbox_iframe)
	
func _on_sword_2d_body_entered(body: Node2D) -> void:
	if not dash_attacking:
		hit_target(sword_damage_multiplier, body, hitbox_iframe, sword_chip_damage, false, Global.Attribute.SLASH)
	else:
		hit_target(dash_attack_damage_multiplier, body, hitbox_iframe, dash_attack_chip_damage, true, Global.Attribute.SLASH, 1, true)

func _on_vision_body_entered(body: Node2D) -> void:
	activated_AI = true
	vision.set_deferred("monitoring", false)

func _on_poison_attack_2d_body_entered(body: Node2D) -> void:
	hit_target(poison_attack_damage_multiplier, body, hitbox_iframe, poison_attack_chip_damage, false, Global.Attribute.POISON)


func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)
