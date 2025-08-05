extends Area2D
class_name PlayerHitbox
@export var player: CharacterBody2D
@export var sound: PolyphonicAudio
@export var state_machine: Node
@export var hitbox: CollisionShape2D
@export var trail: Sprite2D
@export var hit_collision_scene: PackedScene
@export var ice_hit_collision_scene: PackedScene
@export var fire_hit_collision_scene: PackedScene
@export var base_attribute: Array[Global.Attribute]
static var coin_scene: PackedScene = preload("res://SampleProject/extra_scenes/items/money.tscn")
var actual_attributes: Array[Global.Attribute]

const AFFINITY_COST: int = 3

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	adjustHitboxOrientation()
	
	if player == null:
		player = Global.player
		sound = Global.player.sound
	
	if state_machine != null:
		removeHitboxIfNotAttacking()
		
func _on_body_entered(body: Node2D, physical_based_sound: bool = true) -> void:
	actual_attributes = base_attribute.duplicate(true)
	if body is Candle or body is Canister:
		createHitEffect(body)
		body.destroy()
		return
	# Hitting an object that isn't a candle
	if body is RigidBody2D:
		if body.stats.effect_on_destroy:
			createEffects(body, physical_based_sound)
		if "stats" in body and body.stats.destructible:
			body.destroy()
		return
	# Hitting an enemy
	if isAlive(body):
		var damage = calculateDamage(body)
		
		if player.stats.canApplySkill(Skill.Skills.SWORD_HAND):
			damage *= 1.1
		
		player.addWeaponExp()
		
		player.focus_gain_duration.start()
		
		if player.stats.status[player.stats.Status.REFRESHING_AIR] > 0 and player.unlocked_magic:
			player.healMP(2+damage/20)
			player.heal_mp_effect.emitting = true
			
		if player.stats.findItem(Skill.Skills.HOLY_MANUAL, player.stats.skill_inventory) and not (body is Enemy and body.boss):
			Global.enemy_box.visible = true
			Global.enemy_box.label.text = body.stats.enemy_name
			Global.enemy_box.timer.start()
		damage = applyDamage(body, damage, physical_based_sound)
		if kills(body, damage):
			player.addExp(body.stats.EXP)
	if isAlive(body):
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
	if Global.player.enabled_magic and Global.player.stats.Stats["MP"] >= AFFINITY_COST and Global.player.stats.itemEquipped(Relic.Relics.INDIGO_CROSS, "relic") and Global.player.stats.findItem(Skill.Skills.CYAN_ORB, Global.player.stats.skill_inventory):
		actual_attributes.append(Global.Attribute.ICE)
		hit_effect = ice_hit_collision_scene.instantiate()
		if body is not Candle:
			Global.player.stats.Stats["MP"] -= AFFINITY_COST
	else:
		match base_attribute[0]:
			Global.Attribute.HIT:
				hit_effect = hit_collision_scene.instantiate()
			Global.Attribute.SLASH:
				hit_effect = hit_collision_scene.instantiate()
			Global.Attribute.ICE:
				hit_effect = ice_hit_collision_scene.instantiate()
			Global.Attribute.FIRE:
				hit_effect = fire_hit_collision_scene.instantiate()
				
	Global.player.get_parent().add_child(hit_effect)
	hit_effect.position = Vector2(effect_x, effect_y)
	
	if Global.player.stats.itemEquipped(Artifact.Artifacts.GOLD_RING, "artifact") and Global.player.stats.Stats["LCK"] > randi_range(0, 99):
		var coin = coin_scene.instantiate()
		MetSys.get_current_room_instance().call_deferred("add_child", coin)
		coin.global_position = hit_effect.position
		

# Adjusts hitbox according to Hector's facing position
func adjustHitboxOrientation() -> void:
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
func calculateDamage(body: Node2D) -> int:
	var damage: int = max(player.stats.Stats["ATK"] - body.stats.DEF/2, 1)
	const STUD_OF_CONCENTRATION_BOOST: float = 1.07
	
	if player.stats.accessoryEquipped(Accessory.Accessories.STUD_OF_CONCENTRATION) and player.stats.Stats["FP"] >= player.stats.Stats["MFP"]:
		damage *= STUD_OF_CONCENTRATION_BOOST
	
	return damage

# Does the attack kill the target?
func kills(body: Node2D, damage) -> bool:
	return body.stats.HP <= 0

# Generates the effect and applies the damage to the target
func applyDamage(body: Node2D, damage: int, physical_based_sound: bool = true) -> int:
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
	var hit_sounds = ["hard_slash_sfx", "hard_slash_sfx", "hard_slash_sfx", "", "hit_sfx"]
	var weapon = player.stats.equipment["weapon"]
	var attack_type = 4
	if physical_based_sound:
		if weapon != 0:
			attack_type = player.stats.searchItemInCompendium(weapon, player.stats.weapon_compendium).type
			
		if Global.Attribute.SLASH in actual_attributes and body is Enemy and body.blood_particles != null:
			body.blood_particles.restart()
			body.blood_particles.emitting = true
			sound.play_sound_effect_from_library("blood_slash_sfx")
		else:
			sound.play_sound_effect_from_library(hit_sounds[attack_type])
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
	if Global.player.enabled_magic and Global.player.stats.Stats["MP"] >= 3 and Global.player.stats.equipment["relic"] == 1 and Global.player.stats.findItem(4, Global.player.stats.skill_inventory):
		trail.modulate = Color(0.3, 0.8, 1.5, 1)
	else:
		trail.modulate = Color(1, 1, 1, 1)
