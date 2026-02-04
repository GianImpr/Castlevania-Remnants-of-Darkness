extends Enemy

var activated_AI: bool = false
var facing_position: int
var ice_elemental: bool = false
@export var is_moving: bool = true
@export var vision: Area2D
@export var contact_damage_multiplier: float = 1
@export var green_merman: CompressedTexture2D
@export var purple_merman: CompressedTexture2D
@export var blue_merman: CompressedTexture2D

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.body_entered.connect(_on_area_2d_body_entered)
	vision.body_entered.connect(_on_vision_body_entered)
	ice_elemental = bool(randi_range(0,1))
	var palette = randi_range(0,1)
	if ice_elemental:
		if palette == 0:
			sprite.texture = green_merman
		else:
			sprite.texture = blue_merman
	else:
		if palette == 0:
			sprite.texture = purple_merman

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	hit_target(contact_damage_multiplier, body, hitbox_iframe)


func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)

func _on_vision_body_entered(body: Node2D) -> void:
	activated_AI = true
	vision.set_deferred("monitoring", false)
