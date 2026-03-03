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
var is_hurt: bool = false
static var body_hitbox_on_cooldown: bool = false
static var INVULNERABILITY_DURATION: float = 1

func _ready() -> void:
	body_hitbox_on_cooldown = false
	hitbox_iframe.set_collision_mask_value(2, true)


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
	var damage = max((stats.ATK - body.stats.Stats["DEF"]/2)*multiplier, 1)
	var damage_with_chip = damage + chip_damage
	const STONE_DAMAGE_MULTIPLIER: float = 2
	const CONFIDENCE_RING_MULTIPLIER: float = 1.3
	const ENFEEBLE_DAMAGE_MULTIPLIER: float = 1.3

	if body.isGuarding():
		if body.isPerfectGuarding():
			body.stats.Stats["MP"] = min(body.stats.Stats["MMP"], body.stats.Stats["MP"]+floor(damage/10)+10*(int(guard_break)+2))
			body.heal_innocent(floor(damage/10)+1)
			body.stats.Stats["Guard"] = 3
			TrainingSettings.spawnTrainingHeart(TrainingMode.Training.PERFECT_GUARD)
			TrainingSettings.spawnTrainingHeart(TrainingMode.Training.GUARD)
			return 0
		if (damage_with_chip < body.stats.Stats["MHP"]/10 or TrainingSettings.cur_challenge == TrainingMode.Training.GUARD) and body.stats.Stats["Guard"] > 1 and not guard_break:
			TrainingSettings.spawnTrainingHeart(TrainingMode.Training.GUARD)
			body.stats.Stats["Guard"] -= 1
			return 0
		elif damage_with_chip >= body.stats.Stats["MHP"]/10 and body.stats.Stats["Guard"] > 1 and not guard_break:
			damage = min(damage * 0.1 + chip_damage, body.stats.Stats["HP"]-1)
		elif body.stats.Stats["Guard"] == 1 or guard_break:
			damage = damage * 0.6 + chip_damage
		if not guard_break:
			body.stats.Stats["Guard"] -= 1
		else:
			body.stats.Stats["Guard"] = 0
	else:
		body.knockback = knockback
		body.applyHitEffect(attribute)
		
	if not body.isGuarding() or body.stats.Stats["Guard"] == 0:
		match attribute:
			Global.Attribute.STONE:
				body.petrify()
			Global.Attribute.CURSE:
				body.curse()
			Global.Attribute.POISON:
				body.poison()
			Global.Attribute.ENFEEBLE:
				body.enfeeble()
		
	if body.isGuarding() and Global.game.difficulty == Game.Difficulty.SIMPLIFIED:
		if guard_break:
			damage = min(damage*0.6, body.stats.Stats["HP"]/10)
		else:
			damage = 0
			
	if body.state_machine.current_state is HectorPetrified:
		damage *= STONE_DAMAGE_MULTIPLIER
		
	if body.stats.accessoryEquipped(Accessory.Accessories.CONFIDENCE_RING):
		damage *= CONFIDENCE_RING_MULTIPLIER
		
	if body.stats.status[body.stats.Status.ENFEEBLE] > 0:
		damage *= ENFEEBLE_DAMAGE_MULTIPLIER
	
	if damage > body.stats.Stats["HP"] and body.stats.Stats["HP"] > 1 and randi_range(0, 99) < body.stats.Stats["LCK"] and Global.player.stats.itemEquipped(Artifact.Artifacts.MIRACLE_COIN, "artifact"):
		damage = body.stats.Stats["HP"] - 1
		
	if Global.screen == Global.ScreenType.TRAINING:
		return ceil(body.stats.Stats["MHP"] * TrainingSettings.damage_upon_hit / 100)
	
	return damage
	
func apply_damage(body, damage, attack_hitbox = hitbox_iframe, rehit_time: float = 0):
	body.damage_popup.popup(damage, 0)
	body.stats.Stats["HP"] = max(body.stats.Stats["HP"]-damage, 0)
	body.is_hurt = true
	if body.stats.accessoryEquipped(Accessory.Accessories.STOIC_BELT) and not body.isGuarding() and damage < body.stats.Stats["MHP"]*0.07:
		body.is_hurt = false
	attack_hitbox.set_collision_mask_value(2, false)
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
		get_tree().create_timer(INVULNERABILITY_DURATION).timeout.connect(resetInvulnerability)
		var damage = calculate_damage(body, multiplier, chip_damage, guard_break, attribute, knockback)
		apply_damage(body, damage, attack_hitbox, rehit_time)
	if "facing_position" in self:
		body.sprite.flip_h = self.facing_position == 1

func resetHitbox(attack_hitbox: Area2D) -> void:
	if stats.HP > 0:
		attack_hitbox.set_collision_mask_value(2, true)

static func resetInvulnerability() -> void:
	body_hitbox_on_cooldown = false
