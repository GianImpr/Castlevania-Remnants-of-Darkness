extends Area2D
class_name PlayerHitbox
@export var player: CharacterBody2D
@export var sound: PolyphonicAudio
@export var state_machine: Node
@export var hitbox: CollisionShape2D
@export var hit_collision_scene: PackedScene

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	adjustHitboxOrientation()
	removeHitboxIfNotAttacking()
		
func _on_body_entered(body: Node2D) -> void:
	if body is Candle or body is Canister:
		createHitEffect(body)
		body.destroy()
		return
	# Hitting an object that isn't a candle
	if body is RigidBody2D:
		if body.stats.effect_on_destroy:
			createEffects(body)
		body.destroy()
		return
	# Hitting an enemy
	if isAlive(body):
		var damage = calculateDamage(body)
		
		if player.stats.status[player.stats.Status.REFRESHING_AIR] > 0 and player.unlocked_magic:
			player.healMP(2+damage/20)
			player.heal_mp_effect.emitting = true
			
		if player.stats.findItem(2, player.stats.skill_inventory) and not (body is Enemy and body.boss): #Holy Manual
			Global.enemy_box.visible = true
			Global.enemy_box.label.text = body.stats.enemy_name
			Global.enemy_box.timer.start()
		if kills(body, damage):
			player.addExp(body.stats.EXP)
		applyDamage(body, damage)
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
	var coordinatesX: Array[float] = [hitbox.global_position.x-hitbox.shape.size.x/2, hitbox.global_position.x+hitbox.shape.size.x/2, hurtbox.global_position.x+body_size.x/2, hurtbox.global_position.x-body_size.x/2]
	var coordinatesY: Array[float] = [hitbox.global_position.y-hitbox.shape.size.y/2, hitbox.global_position.y+hitbox.shape.size.y/2, hurtbox.global_position.y+body_size.y/2, hurtbox.global_position.y-body_size.y/2]
	coordinatesX.sort()
	coordinatesY.sort()
	var effect_x = (coordinatesX[1]+coordinatesX[2])/2
	var effect_y = (coordinatesY[1]+coordinatesY[2])/2
	var hit_effect = hit_collision_scene.instantiate()
	Global.player.get_parent().add_child(hit_effect)
	hit_effect.position = Vector2(effect_x, effect_y)

# Adjusts hitbox according to Hector's facing position
func adjustHitboxOrientation() -> void:
	if get_parent().flip_h:
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
	return max(player.stats.Stats["ATK"] - body.stats.DEF/2, 1)

# Does the attack kill the target?
func kills(body: Node2D, damage) -> bool:
	return damage >= body.stats.HP

# Generates the effect and applies the damage to the target
func applyDamage(body: Node2D, damage: int) -> void:
	body.damage_popup.popup(damage, 1)
	body.stats.HP -= damage
	createEffects(body)

# Creates the graphical hit effect and the sound effect of the impact
func createEffects(body: Node2D) -> void:
	var hit_sounds = ["hard_slash_sfx", "hit_sfx", "hard_slash_sfx"]
	var weapon = player.stats.equipment["weapon"]
	var attack_type = 1
	if weapon != 0:
		attack_type = player.stats.searchItemInCompendium(weapon, player.stats.weapon_compendium).type	
	sound.play_sound_effect_from_library(hit_sounds[attack_type])
	createHitEffect(body)
	
func applyGlow(body: Node2D, color: Color) -> void:
	body.sprite.self_modulate = color
	
# Is the target living?
func isAlive(body) -> bool:
	if body is not CharacterBody2D:
		return false
	return body.stats.HP > 0
