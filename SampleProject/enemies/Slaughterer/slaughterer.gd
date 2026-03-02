extends Enemy
class_name Slaughterer
var activated_AI: bool = false
var facing_position: int
@export var is_moving: bool = true
@export var vision: Area2D
@export var contact_damage_multiplier: float = 1
@export var punch_damage_multiplier: float = 2
@export var punch_chip_damage: int = 10
@export var punch_hitbox: Area2D

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.area_entered.connect(_on_area_2d_area_entered)
	vision.area_entered.connect(_on_vision_area_entered)
	punch_hitbox.area_entered.connect(_on_punch_hitbox_area_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(contact_damage_multiplier, body, hitbox_iframe)
	
func _on_punch_hitbox_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(punch_damage_multiplier, body, hitbox_iframe, punch_chip_damage, false, StaticGlobal.Attribute.HIT, 1, true)


func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)

func _on_vision_area_entered(area: Area2D) -> void:
	activated_AI = true
	vision.set_deferred("monitoring", false)
