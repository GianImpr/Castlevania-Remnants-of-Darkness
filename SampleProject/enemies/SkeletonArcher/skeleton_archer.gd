extends Enemy
class_name SkeletonArcher

var activated_AI: bool = false
var facing_position: int
@export var is_moving: bool = true
@export var vision: Area2D
@export var contact_damage_multiplier: float = 1
@export var arrow_scene: PackedScene

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.body_entered.connect(_on_area_2d_body_entered)
	vision.body_entered.connect(_on_vision_body_entered)

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

func throwArrow(spawn_offset: Vector2) -> void:
	var arrow = arrow_scene.instantiate()
	arrow.stats.thrower_ATK = stats.ATK
	arrow.z_index = z_index+1
	arrow.direction = facing_position
	arrow.global_position.x = global_position.x+spawn_offset.x*facing_position
	arrow.global_position.y = global_position.y+spawn_offset.y
	MetSys.get_current_room_instance().add_child(arrow)
