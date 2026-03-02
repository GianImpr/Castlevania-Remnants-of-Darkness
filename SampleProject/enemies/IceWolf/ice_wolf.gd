extends Enemy
class_name IceWolf
var activated_AI: bool = false
var facing_position: int
@export var is_moving: bool = true
@export var vision: Area2D
@export var contact_damage_multiplier: float = 1
@export var punch: Area2D
@export var last_punch: Area2D
@export var slide: Area2D
@export var dash: Area2D
@export var shockwave: Area2D
const PUNCH_DAMAGE_MULTIPLIER: float = 1.1
const LAST_PUNCH_DAMAGE_MULTIPLIER: float = 1.3
const DASH_DAMAGE_MULTIPLIER: float = 1.5
const SHOCKWAVE_DAMAGE_MULTIPLIER: float = 2.5
const SLIDE_DAMAGE_MULTIPLIER: float = 1.2
const SLIDE_CHIP_DAMAGE: float = 10
const DASH_CHIP_DAMAGE: float = 15
const SHOCKWAVE_CHIP_DAMAGE: float = 25
const PUNCH_REHIT_RATE: float = 0.2
const REHIT_RATE: float = 1

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.area_entered.connect(_on_area_2d_area_entered)
	vision.area_entered.connect(_on_vision_area_entered)
	punch.area_entered.connect(_on_punch_2d_area_entered)
	last_punch.area_entered.connect(_on_final_punch_2d_area_entered)
	slide.area_entered.connect(_on_slide_2d_area_entered)
	dash.area_entered.connect(_on_dash_2d_area_entered)
	shockwave.area_entered.connect(_on_shockwave_2d_area_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(contact_damage_multiplier, body, hitbox_iframe)
	
func _on_punch_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(PUNCH_DAMAGE_MULTIPLIER, body, punch, 0, false, Global.Attribute.HIT, PUNCH_REHIT_RATE, false)
	
func _on_final_punch_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(LAST_PUNCH_DAMAGE_MULTIPLIER, body, last_punch, 0, false, Global.Attribute.HIT, PUNCH_REHIT_RATE, true)
	
func _on_slide_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(SLIDE_DAMAGE_MULTIPLIER, body, hitbox_iframe, SLIDE_CHIP_DAMAGE, false, Global.Attribute.HIT, REHIT_RATE, true)
	
func _on_dash_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(DASH_DAMAGE_MULTIPLIER, body, hitbox_iframe, DASH_CHIP_DAMAGE, true, Global.Attribute.HIT, REHIT_RATE, true)

func _on_shockwave_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(SHOCKWAVE_DAMAGE_MULTIPLIER, body, hitbox_iframe, SHOCKWAVE_CHIP_DAMAGE, true, Global.Attribute.ICE, REHIT_RATE, true)

func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)

func _on_vision_area_entered(area: Area2D) -> void:
	activated_AI = true
	vision.set_deferred("monitoring", false)
