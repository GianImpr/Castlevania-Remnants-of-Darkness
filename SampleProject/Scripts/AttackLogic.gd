extends Area2D
class_name PlayerHitbox
@export var dmg_multiplier: float = 1
@export var damage_boost: int = 0
@export_range(0, 120, 1, "suffix:frames") var iframes_on_hit: int
@export var player: CharacterBody2D
@export var sound: PolyphonicAudio
@export var state_machine: Node
@export var hitbox: CollisionShape2D
@export var trail: Sprite2D
@export var hit_collision_scene: PackedScene
@export var ice_hit_collision_scene: PackedScene
@export var fire_hit_collision_scene: PackedScene = preload("res://SampleProject/extra_scenes/effects/candle_explosion.tscn")
@export var base_attribute: Array[Global.Attribute]
@export var adjust_facing_position: bool = true
@export var direct_physical_hit: bool = false
@export var dive_kick: bool = false
static var coin_scene: PackedScene = preload("res://SampleProject/extra_scenes/items/money.tscn")
static var heart_scene: PackedScene = preload("res://SampleProject/extra_scenes/items/heart.tscn")
static var orb_scene: PackedScene = preload("res://SampleProject/extra_scenes/effects/heal_orb.tscn")
var actual_attributes: Array[Global.Attribute]

var hit_enemies: Array[Node2D]
var frames_passed: float

const INTENDED_FRAMES_PER_SECOND: int = 60
const AFFINITY_COST: int = 3

const NORMAL_TRAIL = Color(1, 1, 1, 1)
const ICE_TRAIL = Color(0.3, 0.8, 1.5, 1)
const FIRE_TRAIL = Color(1.5, 0.7, 0.3, 1)

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	adjustHitboxOrientation()
	
	if hit_enemies.size() > 0:
		frames_passed += delta*INTENDED_FRAMES_PER_SECOND
	
	if frames_passed >= iframes_on_hit:
		frames_passed = 0
		set_deferred("monitoring", false)
		hit_enemies.clear()
	else:
		set_deferred("monitoring", true)
	
	if player == null:
		player = Global.player
		sound = Global.player.sound
	
	if state_machine != null:
		removeHitboxIfNotAttacking()
		
func _on_body_entered(body: Node2D, physical_based_sound: bool = true) -> void:
	actual_attributes = base_attribute.duplicate(true)
	
	if Global.player.stats.itemEquipped(Weapon.Weapons.BAHG_NAHK, HectorStats.EQUIPMENT_SLOTS.WEAPON) and (name in ["FistHitbox", "UppercutHitbox", "ThunderUppercut"]):
		actual_attributes[actual_attributes.find(Global.Attribute.HIT)] = Global.Attribute.SLASH
	
	if dive_kick and Global.player.state_machine.current_state is HectorDiveKick and (isAlive(body) or body is not CharacterBody2D):
		player.dive_kicking = true
		player.transitionToState("jump")
	if body is Candle or body is Canister or body.get_parent().get_parent() is BreakableStatue:
		if body.get_parent().get_parent() is BreakableStatue:
			createEffects(body)
			body.get_parent().get_parent().takeHit(actual_attributes)
		else:
			createHitEffect(body)
			body.destroy()
		return
	if body is RigidBody2D and body.get_parent() is BreakableWall:
		body.get_parent().takeDamage()
		return
	# Hitting an object that isn't a candle
	if (body is RigidBody2D or body is StaticBody2D) and "stats" in body:
		if body.stats.effect_on_destroy:
			createEffects(body, physical_based_sound)
		if "stats" in body and body.stats.destructible:
			TrainingSettings.spawnTrainingHeart(TrainingMode.Training.PROJECTILES, body.global_position)
			body.destroy()
		return
	# Hitting an enemy
	if body in hit_enemies:
		return
		
	if isAlive(body):
		var damage = calculateDamage(body)
		
		if body is Enemy and body.register_knockback:
			body.is_hurt = true
		
		if player.stats.canApplySkill(Skill.Skills.SWORD_HAND):
			damage *= 1.1
		
		player.addWeaponExp()
		
		player.focus_gain_duration.start()
		
		if player.stats.status[player.stats.Status.REFRESHING_AIR] > 0 and player.unlocked_magic:
			player.healMP(2+damage/20)
			player.heal_mp_effect.emitting = true
			
		if player.stats.findItem(Skill.Skills.HOLY_MANUAL, player.stats.skill_inventory) and not (body is Enemy and (body.boss or body.stats.enemy_name == "")):
			Global.enemy_box.visible = true
			Global.enemy_box.label.text = body.stats.enemy_name
			Global.enemy_box.timer.start()
		damage = applyDamage(body, damage, physical_based_sound)
		if kills(body, damage):
			player.addExp(body.stats.EXP)
			updateKillCount(body.stats.enemy_name)
		else:
			hit_enemies.append(body)
	if isAlive(body) and not ("is_guarding" in body and body.is_guarding):
		if body.stats.DEF > player.stats.Stats["ATK"]/2.5:
			applyGlow(body, Color(-1, -1, 1)) # Blue glow => attack is weak
		else:
			applyGlow(body, Color(1, -1, -1)) # Red glow => attack is strong

# Generates a hit effect and calculates the position where it should spawn
# The calculation is done taking the intersection between attack hitbox and target hurtbox and finding its center
func createHitEffect(body: Node2D) -> void:
	var hurtbox: CollisionShape2D
	if body is Enemy or body is Zombie:
		hurtbox = body.hitbox_iframe.get_child(0)
	elif body.get_parent().get_parent() is BreakableStatue:
		hurtbox = body.get_child(0)
	else:
		hurtbox = body.hitbox_iframe
	var body_size: Vector2
	if hurtbox.shape is RectangleShape2D:
		body_size = hurtbox.shape.size
	elif hurtbox.shape is CircleShape2D:
		body_size = Vector2(hurtbox.shape.radius*2, hurtbox.shape.radius*2)
	var coordinatesX: Array[float] = [hitbox.global_position.x-body_size.x/2, hitbox.global_position.x+body_size.x/2, hurtbox.global_position.x+body_size.x/2, hurtbox.global_position.x-body_size.x/2]
	var coordinatesY: Array[float] = [hitbox.global_position.y-body_size.y/2, hitbox.global_position.y+body_size.y/2, hurtbox.global_position.y+body_size.y/2, hurtbox.global_position.y-body_size.y/2]
	coordinatesX.sort()
	coordinatesY.sort()
	var effect_x = (coordinatesX[1]+coordinatesX[2])/2
	var effect_y = (coordinatesY[1]+coordinatesY[2])/2
	var hit_effect
	var using_affinity: bool = false
	if Global.player.enabled_magic and Global.player.stats.Stats["MP"] >= AFFINITY_COST:
		if Global.player.stats.itemEquipped(Relic.Relics.INDIGO_CROSS, "relic") and Global.player.stats.findItem(Skill.Skills.CYAN_ORB, Global.player.stats.skill_inventory):
			actual_attributes.append(Global.Attribute.ICE)
			hit_effect = ice_hit_collision_scene.instantiate()
			using_affinity = true
			if body is not Candle:
				Global.player.stats.Stats["MP"] -= AFFINITY_COST
		elif Global.player.stats.itemEquipped(Relic.Relics.AGUNIS_LAUREL, "relic") and Global.player.stats.findItem(Skill.Skills.RED_ORB, Global.player.stats.skill_inventory):
			actual_attributes.append(Global.Attribute.FIRE)
			hit_effect = fire_hit_collision_scene.instantiate()
			sound.play_sound_effect_from_library("hit_fire_sfx")
			using_affinity = true
			if body is not Candle:
				Global.player.stats.Stats["MP"] -= AFFINITY_COST
	if not using_affinity:
		match base_attribute[0]:
			Global.Attribute.HIT:
				hit_effect = hit_collision_scene.instantiate()
			Global.Attribute.SLASH:
				hit_effect = hit_collision_scene.instantiate()
			Global.Attribute.ICE:
				hit_effect = ice_hit_collision_scene.instantiate()
			Global.Attribute.FIRE:
				hit_effect = fire_hit_collision_scene.instantiate()
				
	hit_effect.position = Vector2(effect_x, effect_y)
	Global.player.get_parent().add_child(hit_effect)
	
	if body is not Enemy and body is not Zombie:
		return
	
	if Global.player.stats.itemEquipped(Artifact.Artifacts.LITTLE_HAMMER, "artifact") and Global.player.stats.Stats["LCK"] > randi_range(0, 99):
		var coin = coin_scene.instantiate()
		coin.global_position = hit_effect.position
		MetSys.get_current_room_instance().call_deferred("add_child", coin)

	if Global.player.stats.itemEquipped(Artifact.Artifacts.HEART_BROOCH, "artifact") and Global.player.stats.Stats["LCK"] > randi_range(0, 199):
		var heart = heart_scene.instantiate()
		heart.fly_high = true
		heart.global_position = hit_effect.position
		MetSys.get_current_room_instance().call_deferred("add_child", heart)
		
	if Global.player.stats.itemEquipped(Artifact.Artifacts.BLOOD_STONE, "artifact") and Global.player.stats.Stats["LCK"] > randi_range(0, 199):
		var orb = orb_scene.instantiate()
		orb.global_position = hit_effect.position
		MetSys.get_current_room_instance().call_deferred("add_child", orb)


# Adjusts hitbox according to Hector's facing position
func adjustHitboxOrientation() -> void:
	if not adjust_facing_position:
		return
	var reference = get_parent()
	if reference == null or reference is not Sprite2D:
		reference = Global.player.sprite
	if reference.flip_h:
		scale.x = -1
	else:
		scale.x = 1
		
# Disables the hitbox if not attacking.
# This is to avoid hitbox lingering if the player cancels the attack animation
func removeHitboxIfNotAttacking() -> void:
	if not state_machine.current_state.attacking():
		hitbox.set_deferred("disabled", true)

# Calculates the base damage of the move
func calculateDamage(body: Node2D, magical: bool = false) -> int:
	var offensive_stat: int
	var defensive_stat: int
	if magical:
		defensive_stat = body.stats.RES
		offensive_stat = player.stats.Stats["INT"]
	else:
		defensive_stat = body.stats.DEF
		if direct_physical_hit:
			offensive_stat = player.stats.Stats["STR"]/2
		else:
			offensive_stat = player.stats.Stats["ATK"]
			
	if Global.player.stats.canApplySkill(Skill.Skills.PERFORATION):
		for element in actual_attributes:
			if element in body.stats.weaknesses:
				defensive_stat = 0
				
	var damage: int = max(offensive_stat - defensive_stat/2, 1) * dmg_multiplier + damage_boost
	const STUD_OF_CONCENTRATION_BOOST: float = 1.07
	const TIP_DAMAGE_MULTIPLIER: float = 1.2
	const CHARGE_DAMAGE_MULTIPLIERS: Array[float] = [1.2, 1.3, 1.4]
	const CONFIDENCE_RING_MULTIPLIER: float = 1.3
	const WINGED_RING_MULTIPLIER: float = 1.1
	const BLOCKED_DAMAGE_MULTIPLIER: float = 0.1
	const ENFEEBLE_DAMAGE_MULTIPLIER: float = 0.7
	
	if player.stats.accessoryEquipped(Accessory.Accessories.STUD_OF_CONCENTRATION) and player.stats.Stats["FP"] >= player.stats.Stats["MFP"]:
		damage *= STUD_OF_CONCENTRATION_BOOST
	
	if atTipDistance(body) and Global.player.stats.canApplySkill(Skill.Skills.SHARP_EDGE):
		damage *= TIP_DAMAGE_MULTIPLIER
		
	if player.cur_charge != HectorPlayer.Charge.NONE:
		damage *= CHARGE_DAMAGE_MULTIPLIERS[player.cur_charge]
		
	if not Global.player.confidence_ring_timer.is_stopped():
		damage *= CONFIDENCE_RING_MULTIPLIER
		
	if player.stats.accessoryEquipped(Accessory.Accessories.WINGED_RING) and not player.is_on_floor():
		damage *= WINGED_RING_MULTIPLIER
		
	if player.stats.status[player.stats.Status.ENFEEBLE] > 0:
		damage *= ENFEEBLE_DAMAGE_MULTIPLIER
		
	if not TrainingSettings.can_deal_damage and Global.screen == Global.ScreenType.TRAINING:
		return 0
		
	if "is_guarding" in body and body.is_guarding:
		damage *= BLOCKED_DAMAGE_MULTIPLIER
	
	return damage

# Does the attack kill the target?
func kills(body: Node2D, damage) -> bool:
	return body.stats.HP <= 0

# Generates the effect and applies the damage to the target
func applyDamage(body: Node2D, damage: int, physical_based_sound: bool = true) -> int:
	if not ("is_guarding" in body and body.is_guarding):
		createEffects(body, physical_based_sound)
	var multiplier_rate: float = 2
	for element in actual_attributes:
		if element in body.stats.weaknesses:
			multiplier_rate *= 1.5
		elif element in body.stats.tolerances:
			multiplier_rate *= 0.67
	
	multiplier_rate = max(multiplier_rate, 1)
	damage *= log(multiplier_rate) / log(2)
	
	body.damage_popup.popup(damage, 1)
	body.stats.HP -= damage
	return damage

# Creates the graphical hit effect and the sound effect of the impact
func createEffects(body: Node2D, physical_based_sound: bool = true) -> void:
	var hit_sounds = ["hard_slash_sfx", "hard_slash_sfx", "hard_slash_sfx", "hard_slash_sfx", "hit_sfx"]
	var weapon = player.stats.equipment["weapon"]
	var attack_type = 4
	if physical_based_sound:
		if weapon != 0 and not direct_physical_hit:
			attack_type = player.stats.searchItemInCompendium(weapon, player.stats.weapon_compendium).type
			
		if Global.Attribute.SLASH in actual_attributes and (body is Enemy or body is Zombie) and body.blood_particles != null:
			body.blood_particles.restart()
			body.blood_particles.emitting = true
			sound.play_sound_effect_from_library("blood_slash_sfx")
		else:
			if not direct_physical_hit:
				sound.play_sound_effect_from_library(hit_sounds[attack_type])
			else:
				sound.play_sound_effect_from_library("hit_sfx")
	else:
		match base_attribute[0]:
			Global.Attribute.FIRE:
				sound.play_sound_effect_from_library("hit_fire_sfx")
	createHitEffect(body)
	
func applyGlow(body: Node2D, color: Color) -> void:
	body.sprite.self_modulate = color
	
# Is the target living?
func isAlive(body) -> bool:
	if body is not CharacterBody2D:
		return false
	return body.stats.HP > 0

func recolorTrail() -> void:
	if Global.player.enabled_magic and Global.player.stats.Stats["MP"] >= AFFINITY_COST and Global.player.stats.itemEquipped(Relic.Relics.INDIGO_CROSS, "relic") and Global.player.stats.findItem(Skill.Skills.CYAN_ORB, Global.player.stats.skill_inventory):
		trail.modulate = ICE_TRAIL
	elif Global.player.enabled_magic and Global.player.stats.Stats["MP"] >= AFFINITY_COST and Global.player.stats.itemEquipped(Relic.Relics.AGUNIS_LAUREL, "relic") and Global.player.stats.findItem(Skill.Skills.RED_ORB, Global.player.stats.skill_inventory):
		trail.modulate = FIRE_TRAIL
	else:
		trail.modulate = NORMAL_TRAIL

func updateKillCount(enemy_name: String) -> void:
	for i in range(0, Game.enemy_data.size()):
		if enemy_name == Game.enemy_data[i][EnemyEntry.Stats.NAME]:
			if Game.get_singleton().update_player_compendium:
				Game.get_singleton().enemy_compendium[i].killed += 1
			else:
				Global.player.stats.enemy_compendium[i].killed += 1

func atTipDistance(target: Node2D) -> bool:
	const TIP_SIZE: float = 10
	var enemy_pos: float
	if target.hitbox_iframe.get_child(0).shape is RectangleShape2D:
		enemy_pos = target.hitbox_iframe.get_child(0).global_position.x-target.hitbox_iframe.get_child(0).shape.size.x/2
	else:
		return false
	if Global.player.facing_position == -1:
		enemy_pos += target.hitbox_iframe.get_child(0).shape.size.x
	
	var hit_pos: float = hitbox.global_position.x+hitbox.shape.size.x*Global.player.facing_position - enemy_pos
	return (hit_pos < TIP_SIZE and Global.player.facing_position == 1) or (hit_pos > -TIP_SIZE and Global.player.facing_position == -1)
