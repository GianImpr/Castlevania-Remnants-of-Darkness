extends Enemy

var activated_AI: bool = false
var facing_position: int
@export var is_moving: bool = true
@export var vision: Area2D
@export var contact_damage_multiplier: float = 1
@export var tongue: Area2D
@export var aura: Area2D
@export var tongue_damage_multiplier: float = 1.5
@export var tongue_chip_damage: int = 15
@export var aura_damage_multiplier: float = 0.5
@export var aura_chip_damage: int = 0
@export var aura_rehit_time: float = 0.3

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.area_entered.connect(_on_area_2d_area_entered)
	vision.area_entered.connect(_on_vision_area_entered)
	aura.area_entered.connect(_on_aura_2d_area_entered)
	tongue.area_entered.connect(_on_tongue_2d_area_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		velocity += get_gravity() * delta
		
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(contact_damage_multiplier, body, hitbox_iframe)

func _on_tongue_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(tongue_damage_multiplier, body, hitbox_iframe, tongue_chip_damage)
	
func _on_aura_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(aura_damage_multiplier, body, aura, aura_chip_damage, false, Global.Attribute.ENFEEBLE, aura_rehit_time)

func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)

func _on_vision_area_entered(area: Area2D) -> void:
	activated_AI = true
	vision.set_deferred("monitoring", false)
