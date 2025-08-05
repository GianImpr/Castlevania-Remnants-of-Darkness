extends Enemy
class_name Ctulhu

var activated_AI: bool = false
var facing_position: int
var flying: bool = false
@export var is_moving: bool = true
@export var vision: Area2D
@export var contact_damage_multiplier: float = 1
@export var fireball_scene: PackedScene
const FIREBALLS_TO_SHOOT: int = 3
@export var sound: PolyphonicAudio

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.body_entered.connect(_on_area_2d_body_entered)
	vision.body_entered.connect(_on_vision_body_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED and not flying:
		velocity += get_gravity()*2 * delta
		
	#set_collision_mask_value(1, not flying)
		
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


func shootFireballs() -> void:
	sound.play_sound_effect_from_library("fireball")
	const INITIAL_ANGLE = -33
	const ANGLE_STEP = 33
	var fireballs: Array
	for i in range(0, FIREBALLS_TO_SHOOT):
		fireballs.append(generateFireball())
		fireballs[i].rotation_degrees = INITIAL_ANGLE + ANGLE_STEP * i
		fireballs[i].applyDegreeVelocity()
	
func generateFireball():
	const MIDAIR_SPAWN_OFFSET: Vector2 = Vector2(-10, -40)
	const GROUND_SPAWN_OFFSET: Vector2 = Vector2(-10, -30)
	var fireball = fireball_scene.instantiate()
	
	fireball.stats.thrower_ATK = stats.ATK
	
	if facing_position == 1:
		fireball.sprite.scale.x *= -1
		
	if flying:
		fireball.global_position.y = global_position.y + MIDAIR_SPAWN_OFFSET.y
		fireball.global_position.x = global_position.x + MIDAIR_SPAWN_OFFSET.x * facing_position * (-1)
	else:
		fireball.global_position.y = global_position.y + GROUND_SPAWN_OFFSET.y
		fireball.global_position.x = global_position.x + GROUND_SPAWN_OFFSET.x * facing_position * (-1)


	fireball.direction = facing_position
	
	MetSys.get_current_room_instance().add_child(fireball)
	return fireball
