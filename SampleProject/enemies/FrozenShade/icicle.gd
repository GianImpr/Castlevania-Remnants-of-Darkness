extends RigidBody2D
class_name FrozenShadeIcicleProjectile
@export var stats: Projectile
@export var area: Area2D
@export var sprite: Sprite2D
@export var iframes_duration: float = 1
@export var animation: AnimationPlayer
@export var sound: PolyphonicAudio
static var on_cooldown: bool = false
@export var SPEED: float

func _ready() -> void:
	area.area_entered.connect(_on_area_2d_area_entered)
	await alignToPlayer()
	linear_velocity = Vector2(SPEED*cos(rotation-PI/2), SPEED*sin(rotation-PI/2)) * (-1)
	if not animation.current_animation == "destroy":
		sound.play_sound_effect_from_library("throw")

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
	
func alignToPlayer() -> void:
	var aligning_tween: Tween = get_tree().create_tween()
	var cur_player_position: Vector2 = Global.player.global_position
	const ALIGNING_DURATION: float = 0.5
	const COOLDOWN_DURATION: float = 0.3
	const COOLDOWN_DURATION_MIN_MULTIPLIER: float = 1
	const COOLDOWN_DURATION_MAX_MULTIPLIER: float = 5
	aligning_tween.set_trans(Tween.TRANS_QUART)
	aligning_tween.set_ease(Tween.EASE_OUT)
	aligning_tween.tween_property(self, "rotation", global_position.angle_to_point(cur_player_position)-PI/2, ALIGNING_DURATION)
	await aligning_tween.finished
	await get_tree().create_timer(COOLDOWN_DURATION*randf_range(COOLDOWN_DURATION_MIN_MULTIPLIER, COOLDOWN_DURATION_MAX_MULTIPLIER), false).timeout
