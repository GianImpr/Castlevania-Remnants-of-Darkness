extends Enemy
class_name Decarabia

var activated_AI: bool = false
var facing_position: int
@export var is_moving: bool = true
@export var vision: Area2D
@export var contact_damage_multiplier: float = 1
@export var state_machine: StateMachine
const ROTATION_PER_HUNDRED_SPEED: float = PI
@export var turn_cooldown_timer: Timer
signal turning

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.area_entered.connect(_on_area_2d_area_entered)
	vision.area_entered.connect(_on_vision_area_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		velocity += get_gravity()*2 * delta
	
	sprite.rotation -= ROTATION_PER_HUNDRED_SPEED*velocity.x/100*delta*facing_position*(-1)
	remove_glow_if_glowing()
	move_and_slide()
	turn_on_wall()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(contact_damage_multiplier, body, hitbox_iframe)

func turn_on_wall():
	if ray_cast_2d_right.is_colliding() or ray_cast_2d_left.is_colliding() and turn_cooldown_timer.is_stopped():
		turn_cooldown_timer.start()
		facing_position *= -1
		scale.x *= -1
		velocity.x *= -1
		turning.emit()



func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)

func _on_vision_area_entered(area: Area2D) -> void:
	activated_AI = true
	vision.set_deferred("monitoring", false)
