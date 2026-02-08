extends RigidBody2D
class_name BalloonPodProjectile
@export var stats: Projectile
@export var area: Area2D
@export var sprite: Sprite2D
@export var iframes_duration: float = 1
@export var sound: PolyphonicAudio
static var on_cooldown: bool = false
@export var SPAWNING_SPEED: Vector2
@export var FALLING_SPEED: Vector2
@export var shape: CollisionShape2D
@export var small_explosion_scene: PackedScene
const FALLING_SPEED_INITIAL_TWEEN_DURATION: float = 0.5
const MIN_SPEED_MULTIPLIER_X: float = -1
const MAX_SPEED_MULTIPLIER_X: float = 1
const MIN_SPEED_MULTIPLIER_Y: float = 0.5
const MAX_SPEED_MULTIPLIER_Y: float = 1
const MIN_RANDOM_X_SPEED_SWITCH: float = 0.5
const MAX_RANDOM_X_SPEED_SWITCH: float = 1.5
var speed_set: bool = false
var random_initial_speed_direction: int

func _ready() -> void:
	area.body_entered.connect(_on_area_2d_body_entered)
	if randi_range(0,1):
		random_initial_speed_direction = -1
	else:
		random_initial_speed_direction = 1
	await flyUp()
	var falling_speed: Tween = get_tree().create_tween()
	falling_speed.tween_property(self, "linear_velocity:y", FALLING_SPEED.y, FALLING_SPEED_INITIAL_TWEEN_DURATION)
	await falling_speed.finished
	falling_speed = get_tree().create_tween()
	falling_speed.bind_node(self)
	falling_speed.set_loops()
	var TWEEN_DURATION: float = FALLING_SPEED_INITIAL_TWEEN_DURATION*randf_range(MIN_RANDOM_X_SPEED_SWITCH, MAX_RANDOM_X_SPEED_SWITCH)
	falling_speed.tween_property(self, "linear_velocity:x", FALLING_SPEED.x*random_initial_speed_direction, TWEEN_DURATION)
	falling_speed.tween_property(self, "linear_velocity:x", -FALLING_SPEED.x*random_initial_speed_direction, TWEEN_DURATION)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_hurt and not on_cooldown:
		stats.apply_damage(body, stats.calculate_damage(body))
		on_cooldown = true
		if stats.destroy_on_contact:
			destroy()
		get_tree().create_timer(iframes_duration).timeout.connect(func(): on_cooldown = false)
	
func destroy():
	const DELETE_AFTER_SECONDS: float = 1
	area.set_deferred("monitoring", false)
	shape.set_deferred("disabled", true)
	linear_velocity = Vector2.ZERO
	sprite.visible = false
	sound.play_sound_effect_from_library("destroy")
	var explosion = small_explosion_scene.instantiate()
	explosion.global_position = global_position
	MetSys.get_current_room_instance().add_child(explosion)
	get_tree().create_timer(DELETE_AFTER_SECONDS, false).timeout.connect(queue_free)
	
	
func flyUp() -> void:
	var flying_tween: Tween = get_tree().create_tween()
	var spawning_speed: Vector2
	const FLIGHT_DURATION: float = 0.2
	spawning_speed.x = SPAWNING_SPEED.x * randf_range(MIN_SPEED_MULTIPLIER_X, MAX_SPEED_MULTIPLIER_X)
	spawning_speed.y = SPAWNING_SPEED.y * randf_range(MIN_SPEED_MULTIPLIER_Y, MAX_SPEED_MULTIPLIER_Y)
	flying_tween.set_trans(Tween.TRANS_SINE)
	flying_tween.set_ease(Tween.EASE_OUT)
	flying_tween.tween_property(self, "linear_velocity", spawning_speed, FLIGHT_DURATION)
	await flying_tween.finished
