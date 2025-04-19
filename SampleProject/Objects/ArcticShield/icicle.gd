extends RigidBody2D
class_name Icicle

@export var acceleration: float
@export var max_speed: float
var power: int
var direction: int = 1
@export var magical: bool
@export var base_HP: int = 30
@export var hitbox: CollisionShape2D
@export var sound: PolyphonicAudio
@export var hit_collision_scene: PackedScene
@export var animation: AnimationPlayer
@export var area: Area2D
var body_covered: Array[Enemy]

func _ready():
	area.set_deferred("monitoring", false)
	base_HP += Global.player.stats.Stats["INT"]

func _physics_process(delta: float) -> void:
	if animation.current_animation == "travel":
		area.set_deferred("monitoring", true)
		linear_velocity.x = min(abs(max_speed), abs(linear_velocity.x+(acceleration*direction)))*sign(direction)
		move_local_x(delta)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body is Enemy or body is Zombie) and not body in body_covered:
		if is_alive(body):
			var damage = calculate_damage(body)
			take_damage(min(body.stats.HP, damage))
			if kills(body, damage):
				Global.player.addExp(body.stats.EXP)
			else:
				body_covered.append(body)
			apply_damage(body, damage)
		if is_alive(body):
			if body.stats.DEF > power/2.5:
				apply_glow(body, Color(-1, -1, 1))
			else:
				apply_glow(body, Color(1, -1, -1))
	if body is FlameHazard:
		create_effects(body)
		body.destroy()
		destroy()

func create_hit_effect(body: Node2D) -> void:
	var hurtbox: CollisionShape2D
	if body is Enemy or body is Zombie:
		hurtbox = body.hitbox_iframe.get_child(0)
	else:
		hurtbox = body.hitbox_iframe
	var body_size: Vector2
	if hurtbox.shape is RectangleShape2D:
		body_size = hurtbox.shape.size
	elif hurtbox.shape is CircleShape2D:
		body_size = Vector2(hurtbox.shape.radius*2, hurtbox.shape.radius*2)
	var coordinatesX: Array[float] = [hitbox.global_position.x-hitbox.shape.size.x/2, hitbox.global_position.x+hitbox.shape.size.x/2, hurtbox.global_position.x+body_size.x/2, hurtbox.global_position.x-body_size.x/2]
	var coordinatesY: Array[float] = [hitbox.global_position.y-hitbox.shape.size.y/2, hitbox.global_position.y+hitbox.shape.size.y/2, hurtbox.global_position.y+body_size.y/2, hurtbox.global_position.y-body_size.y/2]
	coordinatesX.sort()
	coordinatesY.sort()
	var effect_x = (coordinatesX[1]+coordinatesX[2])/2
	var effect_y = (coordinatesY[1]+coordinatesY[2])/2
	var hit_effect = hit_collision_scene.instantiate()
	Global.player.get_parent().add_child(hit_effect)
	hit_effect.position = Vector2(effect_x, effect_y)
	
func calculate_damage(body: Node2D) -> int:
	if magical:
		return power - body.stats.RES/2
	else:
		return power - body.stats.DEF/2
	
func kills(body: Node2D, damage) -> bool:
	return damage >= body.stats.HP
	
func apply_damage(body: Node2D, damage: int):
	body.damage_popup.popup(damage, 1)
	body.stats.HP -= damage
	create_effects(body)
	
func create_effects(body: Node2D):
	sound.play_sound_effect_from_library("hit_sfx")
	sound.play_sound_effect_from_library("ice")
	create_hit_effect(body)
	
func apply_glow(body: Node2D, color: Color):
	body.sprite.self_modulate = color
	
func is_alive(body):
	if body is not CharacterBody2D:
		return false
	return body.stats.HP > 0

func change_parent():
	var location = global_position
	var old_parent = get_parent()
	get_parent().remove_child(self)
	old_parent.get_parent().get_parent().add_child(self)
	global_position = location

func take_damage(damage: int) -> void:
	base_HP -= damage
	if base_HP <= 0:
		destroy()

func destroy():
	animation.play("destroy")
