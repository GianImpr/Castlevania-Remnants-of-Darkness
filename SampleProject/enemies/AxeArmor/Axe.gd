extends RigidBody2D
@export var stats: Projectile
@export var sprite: Sprite2D
@export var hitbox_iframe: CollisionShape2D
@export var animation: AnimationPlayer
@export var hurtbox: CollisionShape2D
@export var sound: PolyphonicAudio
@export var slowdown_timer: Timer
@export var lifespan_timer: Timer
@export var attribute: Global.Attribute = Global.Attribute.SLASH
var thrower: Enemy
var going_back: bool = false
var direction: int
var hit: bool = false
var max_speed: float
var time_to_slowdown: bool = false

func _ready() -> void:
	slowdown_timer.start()

func _physics_process(delta: float) -> void:
	if max_speed == 0:
		max_speed = linear_velocity.x

	if not hit:
		if not going_back and time_to_slowdown:
			linear_velocity.x *= 0.6
		elif going_back:
			linear_velocity.x = min(abs(linear_velocity.x * 1.2), abs(max_speed))*direction*(-1)
			
		if not going_back and abs(linear_velocity.x) < 70:
			linear_velocity.x = -80 * direction
			going_back = true
			lifespan_timer.start()
		
	move_local_x(delta)

func calculate_damage(body, multiplier) -> int:
	return stats.calculate_damage(body, multiplier)
		
	
func apply_damage(body, damage):
	body.damage_popup.popup(damage, 0)
	body.stats.Stats["HP"] -= damage
	body.is_hurt = true
	
func destroy():
	set_deferred("gravity_scale", 1)
	linear_velocity.x = 0
	hurtbox.set_deferred("disabled", true)
	hitbox_iframe.set_deferred("disabled", true)
	hit = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	var multiplier = 1
	if not body.is_hurt:
		var damage = calculate_damage(body, multiplier)
		apply_damage(body, damage)
	if stats.destroy_on_contact:
		destroy()


func _on_slowdown_timeout() -> void:
	time_to_slowdown = true


func _on_lifespan_timeout() -> void:
	destroy()
