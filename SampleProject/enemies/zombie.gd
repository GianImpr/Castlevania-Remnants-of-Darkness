extends CharacterBody2D
class_name Zombie
var direction := 1
@export var sprite: Sprite2D
@export var hitbox: Area2D
@export var stats: EnemyStats
@export var damage_popup: DamagePopup
@export var iframe_timer: Timer
@export var hitbox_iframe: Area2D
@onready var ray_cast_2d_left: RayCast2D = $RayCast2DLeft
@onready var ray_cast_2d_right: RayCast2D = $RayCast2DRight
@export var attribute: Global.Attribute = Global.Attribute.HIT

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity()*2 * delta
		
	turn_on_wall()
	remove_glow_if_glowing()
	
	move_and_slide()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	var multiplier = 1
	if not body.is_hurt:
		var damage = calculate_damage(body, multiplier)
		apply_damage(body, damage)



	
func _on_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.set_deferred("monitoring", true)
	
func turn_on_wall():
	if ray_cast_2d_right.is_colliding():
		direction = -1
		sprite.flip_h = true
	elif ray_cast_2d_left.is_colliding():
		direction = 1
		sprite.flip_h = false
		
func remove_glow_if_glowing():
	if sprite.self_modulate != Color(1,1,1):
		sprite.self_modulate = Color(min(sprite.self_modulate.r+0.12, 1), min(sprite.self_modulate.g+0.12, 1), min(sprite.self_modulate.b+0.12, 1))

func calculate_damage(body, multiplier) -> int:
	var damage
	damage = max((stats.ATK - body.stats.Stats["DEF"]/2)*multiplier, 1)
		
	if body.isGuarding():
		if body.isPerfectGuarding():
			body.stats.Stats["MP"] = min(body.stats.Stats["MMP"], body.stats.Stats["MP"]+floor(damage/10)+10)
			body.heal_innocent(floor(damage/10)+1)
			body.stats.Stats["Guard"] = 3
			return 0
		if damage < body.stats.Stats["MHP"]/10 and body.stats.Stats["Guard"] > 1:
			damage = 0
		elif damage >= body.stats.Stats["MHP"]/10 and body.stats.Stats["Guard"] > 1:
			damage = min(damage*0.2, body.stats.Stats["HP"]-1)
		elif body.stats.Stats["Guard"] == 1:
			damage *= 0.6
		body.stats.Stats["Guard"] -= 1
	else:
		body.applyHitEffect(attribute)
	return damage
	
func apply_damage(body, damage):
	body.damage_popup.popup(damage, 0)
	body.stats.Stats["HP"] -= damage
	body.is_hurt = true
	hitbox_iframe.set_deferred("monitoring", false)
	iframe_timer.start()
