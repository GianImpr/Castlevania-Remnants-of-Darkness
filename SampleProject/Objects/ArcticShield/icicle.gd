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
@export var element: Global.Attribute
var body_covered: Array[Enemy]

func _ready():
	area.set_deferred("monitoring", false)
	base_HP += Global.player.stats.Stats["INT"]
	if Global.player.stats.findItem(Skill.Skills.CYAN_ORB, Global.player.stats.skill_inventory):
		base_HP *= 1.5

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
			damage = apply_damage(body, damage)
			if kills(body, damage):
				Global.player.addExp(body.stats.EXP)
			else:
				body_covered.append(body)
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
	hit_effect.position = Vector2(effect_x, effect_y)
	Global.player.get_parent().add_child(hit_effect)
	
func calculate_damage(body: Node2D) -> int:
	if magical:
		return power - body.stats.RES/2
	else:
		return power - body.stats.DEF/2
	
func kills(body: Node2D, damage) -> bool:
	return body.stats.HP <= 0
	
func apply_damage(body: Node2D, damage: int) -> int:
	create_effects(body)
	var multiplier_rate: float = 2
	if element in body.stats.weaknesses:
		multiplier_rate *= 1.5
	elif element in body.stats.tolerances:
		multiplier_rate *= 0.67
	
	multiplier_rate = max(multiplier_rate, 1)
	damage *= log(multiplier_rate) / log(2)
	
	body.damage_popup.popup(damage, 1)
	body.stats.HP -= damage
	return damage
	
func create_effects(body: Node2D):
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
	MetSys.current_room.add_child(self)
	global_position = location
	reset_physics_interpolation()

func take_damage(damage: int) -> void:
	base_HP -= damage
	if base_HP <= 0:
		destroy()

func destroy():
	animation.play("destroy")
