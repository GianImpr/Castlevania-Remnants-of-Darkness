extends RigidBody2D
@export var stats: Projectile
@export var sprite: Sprite2D
@export var hitbox_iframe: CollisionShape2D
@export var animation: AnimationPlayer
@export var hurtbox: CollisionShape2D
@export var sound: PolyphonicAudio
@export var attribute: Global.Attribute = Global.Attribute.HIT
var thrower_ATK: int
var thrower: Enemy

func _physics_process(delta: float) -> void:
	move_local_x(delta)
	if abs(linear_velocity) < Vector2(20, 20) or thrower == null:
		destroy()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_hurt:
		var damage = calculate_damage(body)
		apply_damage(body, damage)
	if stats.destroy_on_contact:
		destroy()

func calculate_damage(body) -> int:
	return stats.calculate_damage(body)
		
func apply_damage(body, damage):
	body.damage_popup.popup(damage, 0)
	body.stats.Stats["HP"] -= damage
	body.is_hurt = true
	
func destroy():
	set_deferred("sleeping", true)
	animation.play("destroy", -1, 1.5)
