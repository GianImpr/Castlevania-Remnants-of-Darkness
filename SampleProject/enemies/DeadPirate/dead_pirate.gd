extends Enemy
class_name DeadPirate
var activated_AI: bool = false
var facing_position: int
@export var is_moving: bool = true
@export var vision: Area2D
@export var contact_damage_multiplier: float = 1
@export var sword: Area2D
@export var anti_air: Area2D
@export var backturned_damage_multiplier: float = 2
@export var sword_damage_multiplier: float = 1.5
@export var anti_air_damage_multiplier: float = 1.3
@export var trail: Sprite2D
@export var anti_trail: Sprite2D
var trail_tween: Tween
var attacks: Array[String] = ["hopswing", "swing", "sneak"]
const ATTACK_FROM_RANGE: float = 150
var sword_guard_break: bool = false
const SWORD_CHIP_DAMAGE: int = 15

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.area_entered.connect(_on_area_2d_area_entered)
	vision.area_entered.connect(_on_vision_area_entered)
	sword.area_entered.connect(_on_sword_area_entered)
	anti_air.area_entered.connect(_on_anti_air_area_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(contact_damage_multiplier, body, hitbox_iframe)
	
func _on_sword_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	var damage_multiplier: float = sword_damage_multiplier
	var knockback: bool = false
	var chip_damage: int = 0
	if hittingFromBehind(body):
		damage_multiplier *= backturned_damage_multiplier
		knockback = true
		chip_damage = SWORD_CHIP_DAMAGE
		makeTrailRed(trail)
	hit_target(damage_multiplier, body, sword, chip_damage, sword_guard_break, Global.Attribute.HIT, 0.2, knockback)

func _on_anti_air_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	var damage_multiplier: float = anti_air_damage_multiplier
	if hittingFromBehind(body):
		damage_multiplier *= backturned_damage_multiplier
		makeTrailRed(anti_trail)
	hit_target(damage_multiplier, body)


func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)

func _on_vision_area_entered(area: Area2D) -> void:
	activated_AI = true
	vision.set_deferred("monitoring", false)

func hittingFromBehind(area: Area2D) -> bool:
	var body = area.get_parent()
	return facing_position == body.facing_position

func makeTrailRed(trail_sprite: Sprite2D) -> void:
	const TRAIL_DURATION: float = 0.5
	trail_tween = get_tree().create_tween()
	trail_tween.tween_property(trail_sprite, "modulate", Color.WHITE, TRAIL_DURATION).from(Color.RED)

func playerInAir() -> bool:
	return not Global.player.is_on_floor() and Global.player.global_position.y < global_position.y
