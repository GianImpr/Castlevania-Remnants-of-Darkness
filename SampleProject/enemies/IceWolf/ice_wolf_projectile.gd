extends RigidBody2D
class_name IceWolfProjectileObject
@export var stats: Projectile
@export var area: Area2D
@export var sprite: Sprite2D
@export var iframes_duration: float = 1
@export var animation: AnimationPlayer
@export var sound: PolyphonicAudio
static var on_cooldown: bool = false
const SPEED: Vector2 = Vector2(560, -400)
const ACCELERATION_DURATION: float = 0.7
const FREE_AFTER_SECONDS: float = 3
var direction: int = -1

func _ready() -> void:
	area.area_entered.connect(_on_area_2d_area_entered)
	get_tree().create_timer(FREE_AFTER_SECONDS, false).timeout.connect(queue_free)
	var acceleration_tween: Tween = get_tree().create_tween()
	acceleration_tween.tween_property(self, "linear_velocity", Vector2(0, SPEED.y), ACCELERATION_DURATION).from(Vector2(SPEED.x*direction, 0))

func _physics_process(delta: float) -> void:
	position = position + linear_velocity * delta

func _on_area_2d_area_entered(area_node: Area2D) -> void:
	var body = area_node.get_parent()
	if not body.is_hurt and not on_cooldown:
		stats.apply_damage(body, stats.calculate_damage(body))
		on_cooldown = true
		if stats.destroy_on_contact:
			destroy()
		get_tree().create_timer(iframes_duration).timeout.connect(func(): on_cooldown = false)
	
func destroy():
	linear_velocity = Vector2.ZERO
	sound.play_sound_effect_from_library("destroy")
	animation.play("destroy")
