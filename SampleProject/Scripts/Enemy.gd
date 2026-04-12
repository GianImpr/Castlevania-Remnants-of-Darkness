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
@export var blood_particles: CPUParticles2D
@export var register_knockback: bool = false
@export var visibility_notifier: VisibleOnScreenNotifier2D
@export var idle_states: Array[String] = ["idle", "dying"]
var is_hurt: bool = false
var stay_idle: bool = false
@export var reset_idle_when_staying_idle: bool = false
static var body_hitbox_on_cooldown: bool = false
static var INVULNERABILITY_DURATION: float = 1

func _ready() -> void:
	body_hitbox_on_cooldown = false
	hitbox_iframe.set_collision_mask_value(2, true)
	if visibility_notifier:
		stay_idle = not visibility_notifier.is_on_screen()
		visibility_notifier.screen_entered.connect(setStayIdle.bind(false))
		visibility_notifier.screen_exited.connect(setStayIdle.bind(true))


func _process(delta: float) -> void:
	hitbox_iframe.set_collision_mask_value(2, (not body_hitbox_on_cooldown))
	
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

func calculate_damage(body, multiplier, chip_damage: int = 0, guard_break: bool = false, attribute: Global.Attribute = Global.Attribute.HIT, knockback: bool = false) -> int:
	return body.stats.calculateDamageTaken(stats.ATK, multiplier, chip_damage, guard_break, attribute, knockback)
	
func apply_damage(body, damage, attack_hitbox = hitbox_iframe, rehit_time: float = 0):
	body.damage_popup.popup(damage, 0)
	
	if body is HectorPlayer:
		body.stats.Stats["HP"] = max(body.stats.Stats["HP"]-damage, 0)
		if body.stats.accessoryEquipped(Accessory.Accessories.STOIC_BELT) and not body.isGuarding() and damage < body.stats.Stats["MHP"]*0.07:
			body.is_hurt = false
		body.is_hurt = true
		attack_hitbox.set_collision_mask_value(2, false)
	elif body is InnocentDevil:
		body.stats.Stats["Hearts"] = max(body.stats.Stats["Hearts"]-damage, 0)
		body.is_hurt = true
		attack_hitbox.set_collision_mask_value(14, false)
		
	if rehit_time > 0:
		var iframes_timer: Timer = Timer.new()
		add_child(iframes_timer)
		iframes_timer.wait_time = rehit_time
		iframes_timer.start()
		await iframes_timer.timeout
		resetHitbox(attack_hitbox)
		iframes_timer.queue_free()

func hit_target(multiplier: float, body, attack_hitbox = hitbox_iframe, chip_damage: int = 0, guard_break: bool = false, attribute: Global.Attribute = Global.Attribute.HIT, rehit_time: float = 1, knockback: bool = false):
	if not body_hitbox_on_cooldown or attack_hitbox != hitbox_iframe:
		body_hitbox_on_cooldown = true
		get_tree().create_timer(INVULNERABILITY_DURATION, false).timeout.connect(resetInvulnerability)
		var damage = calculate_damage(body, multiplier, chip_damage, guard_break, attribute, knockback)
		apply_damage(body, damage, attack_hitbox, rehit_time)
	if "facing_position" in self:
		if "sprite" in body:
			body.sprite.flip_h = self.facing_position == 1
		elif body is InnocentDevil:
			if self.facing_position != body.facing_position:
				body.state_machine.current_state.turn_around()

func resetHitbox(attack_hitbox: Area2D) -> void:
	if stats.HP > 0:
		attack_hitbox.set_collision_mask_value(2, true)
		attack_hitbox.set_collision_mask_value(14, true)

static func resetInvulnerability() -> void:
	body_hitbox_on_cooldown = false

func setStayIdle(value: bool) -> void:
	stay_idle = value

func getHurtbox() -> CollisionShape2D:
	for child in get_children():
		if child is CollisionShape2D:
			return child
	return null
