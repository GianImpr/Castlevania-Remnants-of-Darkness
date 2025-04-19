extends CharacterBody2D
class_name Enemy
var direction := 1
@export var boss: bool = false
@export var sprite: Sprite2D
@export var hitbox: Area2D
@export var stats: EnemyStats
@export var damage_popup: DamagePopup
@export var iframe_timer: Timer
@export var hitbox_iframe: Area2D
@export var ray_cast_2d_left: RayCast2D
@export var ray_cast_2d_right: RayCast2D
static var body_hitbox_on_cooldown: bool = false
static var body_hitbox_cooldown_timer: Timer
static var INVULNERABILITY_DURATION: float = 1

func _ready() -> void:
	if body_hitbox_cooldown_timer != null:
		body_hitbox_cooldown_timer.autostart = true
	else:
		body_hitbox_on_cooldown = false
		hitbox_iframe.set_collision_mask_value(2, true)


func _process(delta: float) -> void:
	if body_hitbox_cooldown_timer != null:
		hitbox_iframe.set_collision_mask_value(2, (not body_hitbox_on_cooldown or body_hitbox_cooldown_timer.is_stopped()))
	
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

func calculate_damage(body, multiplier, chip_damage: int = 0, guard_break: bool = false, attribute: Global.Attribute = Global.Attribute.HIT) -> int:
	var damage = max((stats.ATK - body.stats.Stats["DEF"]/2)*multiplier, 1)
	var damage_with_chip = damage + chip_damage
		
	if body.isGuarding():
		if body.isPerfectGuarding():
			body.stats.Stats["MP"] = min(body.stats.Stats["MMP"], body.stats.Stats["MP"]+floor(damage/10)+10*(int(guard_break)+2))
			body.heal_innocent(floor(damage/10)+1)
			body.stats.Stats["Guard"] = 3
			return 0
		if damage_with_chip < body.stats.Stats["MHP"]/10 and body.stats.Stats["Guard"] > 1 and not guard_break:
			damage = 0
		elif damage_with_chip >= body.stats.Stats["MHP"]/10 and body.stats.Stats["Guard"] > 1 and not guard_break:
			damage = min(damage * 0.2 + chip_damage, body.stats.Stats["HP"]-1)
		elif body.stats.Stats["Guard"] == 1 or guard_break:
			damage = damage * 0.6 + chip_damage
		if not guard_break:
			body.stats.Stats["Guard"] -= 1
		else:
			body.stats.Stats["Guard"] = 0
	else:
		body.applyHitEffect(attribute)
	return damage
	
func apply_damage(body, damage, attack_hitbox = hitbox_iframe, rehit_time: float = 0):
	body.damage_popup.popup(damage, 0)
	body.stats.Stats["HP"] = max(body.stats.Stats["HP"]-damage, 0)
	body.is_hurt = true
	attack_hitbox.set_deferred("monitoring", false)
	if rehit_time > 0:
		var iframes_timer: Timer = Timer.new()
		add_child(iframes_timer)
		iframes_timer.wait_time = rehit_time
		iframes_timer.start()
		await iframes_timer.timeout
		resetHitbox(attack_hitbox)
		iframes_timer.queue_free()

func hit_target(multiplier: float, body, attack_hitbox = hitbox_iframe, chip_damage: int = 0, guard_break: bool = false, attribute: Global.Attribute = Global.Attribute.HIT, rehit_time: float = 1):
	if not body_hitbox_on_cooldown:
		body_hitbox_on_cooldown = true
		if body_hitbox_cooldown_timer == null:
			body_hitbox_cooldown_timer = Timer.new()
			body_hitbox_cooldown_timer.one_shot = true
			body_hitbox_cooldown_timer.timeout.connect(resetInvulnerability)
			add_child(body_hitbox_cooldown_timer)
		body_hitbox_cooldown_timer.start(INVULNERABILITY_DURATION)
		var damage = calculate_damage(body, multiplier, chip_damage, guard_break, attribute)
		apply_damage(body, damage, attack_hitbox, rehit_time)

func resetHitbox(attack_hitbox: Area2D) -> void:
	if stats.HP > 0:
		attack_hitbox.set_deferred("monitoring", true)

func resetInvulnerability() -> void:
	body_hitbox_on_cooldown = false
