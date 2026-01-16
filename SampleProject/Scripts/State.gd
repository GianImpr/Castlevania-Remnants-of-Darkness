extends Node
class_name State
signal Transitioned
var player: CharacterBody2D
var animation: AnimationPlayer
var sound
var voice
@export var attack_state: bool = false
const Actions = {
	JUMP = "jump",
	BACKDASH = "backdash",
	CROUCH = "crouch"
}

enum AttackType {
	GROUND,
	AIR,
	CROUCH
}

func _ready() -> void:
	if player == Global.player:
		HectorCrouchAttack.getWeaponAttackSound = get_attack_sound
		HectorCrouchAttack.getHectorAttackSound = get_hector_attack_sound

func enter():
	pass
	
func exit():
	pass
	
func Update(_delta: float):
	pass
	
func Physics_Update(_delta: float):
	pass

#Allows the player to perform an action in a certain state
func can_perform(anim_name: String, just_pressed: bool):
	if just_pressed:
		if InputBuffer.is_action_press_buffered(anim_name):
			Transitioned.emit(self, anim_name)
	else:
		if Input.is_action_pressed(anim_name):
			Transitioned.emit(self, anim_name)

#Allows the player to run in a certain state
func run_without_start_anim(skip_run_start_animation: bool):
	if player.direction:
		player.skip_run_start = skip_run_start_animation
		Transitioned.emit(self, "run")

#Allows the player to fall in a certain state
func can_fall(coyote_effect: bool):
	if not player.is_on_floor():
		if coyote_effect:
			player.coyote_timer.start()
		Transitioned.emit(self, "falling")

#Allows the player to drop from ledges in a certain state
func can_drop_ledge():
	const ONE_WAY_PLATFORM_LAYER: int = 13
	const IGNORE_PLATFORMS_FOR_SECONDS: float = 0.3
	if player.is_on_floor() and InputBuffer.is_action_press_buffered("jump") and Input.is_action_pressed("crouch"):
		player.set_collision_mask_value(ONE_WAY_PLATFORM_LAYER, false)
		get_tree().create_timer(IGNORE_PLATFORMS_FOR_SECONDS, false).timeout.connect(func(): player.set_collision_mask_value(ONE_WAY_PLATFORM_LAYER, true))

#Allows the player to guard if they have Fortitude Gauntlet (Skill ID 1)
func can_guard():
	if player.stats.findItem(Skill.Skills.FORTITUDE_GAUNTLET, player.stats.skill_inventory):
		can_perform("guard", false)
		player.stats.Stats["Guard"] = max(player.stats.Stats["Guard"], 1)
	else:
		player.stats.Stats["Guard"] = 0

#Allows the player to turnaround
func can_turn():
	if player.direction == 1:
		player.sprite.flip_h = false
	elif player.direction == -1:
		player.sprite.flip_h = true

#Allows the player to move, with possibility to retain momentum
#This only applies movement, without changing animation, so it is different than
#can_run_without_anim
func can_move_with_momentum(keep_momentum: bool):
	const MOMENTUM_DECELERATION: float = 0.91
	if player.direction:
		player.velocity.x = player.direction * player.SPEED
	else:
		if keep_momentum:
			player.velocity.x *= MOMENTUM_DECELERATION
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)

func remove_momentum():
	player.velocity.x = 0
	
#Checks if the player is currently guarding an attack
#and transition to the appropriate new state
func check_is_blocking():
	if player.is_hurt and player.stats.Stats["HP"] > 0:
		if (self is HectorJump or self is HectorFalling) and player.willPerfectGuard():
			Transitioned.emit(self, "Guard_perfect_air")
			return
		elif self is HectorJump or self is HectorFalling:
			return
			
		if player.willPerfectGuard():
			Transitioned.emit(self, "Guard_perfect")
		elif player.stats.Stats["Guard"] > 0:
			Transitioned.emit(self, "Guard_blocking")
		else:
			Transitioned.emit(self, "Guard_break")

#Checks if the player got hit and if the hit was guarded
func check_is_hurt():
	if player.state_machine.current_state is HectorGuardPerfectAir:
		return
		
	if player.stats.current_status == player.stats.Ailment.STONE:
		Transitioned.emit(self, "petrified")
		return
		
	if player.is_hurt and player.stats.Stats["HP"] > 0:
		if player.stats.accessoryEquipped(Accessory.Accessories.BLOOD_CLOAK):
			player.activateBloodCloak()
		player.current_hits_taken_before_iframes += 1
		player.mercy_invincibility_hit_threshold_reset.start()
		if player.is_on_floor() and not self is HectorCrouch and player.current_hits_taken_before_iframes != player.IFRAMES_HIT_THRESHOLD:
			if player.knockback or (TrainingSettings.cur_challenge == TrainingMode.Training.QUICK_RECOVER and Global.screen == Global.ScreenType.TRAINING):
				Transitioned.emit(self, "damage_knockback")
			else:
				Transitioned.emit(self, "damage")
		elif not player.is_on_floor():
			Transitioned.emit(self, "damage_air")
		elif player.current_hits_taken_before_iframes != player.IFRAMES_HIT_THRESHOLD:
			Transitioned.emit(self, "damage")
		else:
			Transitioned.emit(self, "damage_mercy")
		var voice_clip = randi_range(0, 2)
		if voice_clip > 0 and player.is_on_floor() and player.current_hits_taken_before_iframes != player.IFRAMES_HIT_THRESHOLD and not player.knockback:
			voice.play_sound_effect_from_library("Hit" + str(voice_clip))
		elif voice_clip > 0 and (not player.is_on_floor() or player.current_hits_taken_before_iframes == player.IFRAMES_HIT_THRESHOLD):
			voice.play_sound_effect_from_library("HeavyHit")
	elif player.stats.Stats["HP"] == 0:
		sound.play_sound_effect_from_library("damage")

#Tells if the player is currently attacking
func attacking() -> bool:
	return attack_state

#Allows the player to attack in a certain state
func can_attack():
	if self != player.state_machine.current_state:
		return
	
	#Check command inputs from unlocked special moves
	for skill in player.stats.skill_inventory:
		var cur_skill: Skill = player.stats.skill_compendium[skill["id"]-1]
		var state_to_transition_to: String = cur_skill.transitions_into_state
		var stat_to_consume: String
		
		match cur_skill.cost_type:
			Skill.CostType.HP:
				stat_to_consume = "HP"
			Skill.CostType.MP:
				stat_to_consume = "MP"
			Skill.CostType.SP:
				stat_to_consume = "SP"
			Skill.CostType.FP:
				stat_to_consume = "FP"
				
		#Not a command input move or wrong weapon type or insufficient resources
		if cur_skill.command_input.size() == 0 or player.stats.getCurrentWeaponType() != cur_skill.weapon_type or player.stats.Stats[stat_to_consume] < cur_skill.cost_value:
			continue
		
		if InputBuffer.checkCommandInput(cur_skill.command_input, 50):
			TrainingSettings.spawnTrainingHeart(TrainingMode.Training.TECHNIQUES)
			Transitioned.emit(self, state_to_transition_to)
			player.stats.Stats[stat_to_consume] -= cur_skill.cost_value
			get_hector_attack_sound()
			return
		
	if InputBuffer.is_action_press_buffered("attack"):
		if (self is HectorCrouch or self is HectorRise) and player.can_crouch_attack:
			Transitioned.emit(self, "crouch_attack")
			swingWeapon(AttackType.CROUCH)
		elif not player.is_on_floor():
			Transitioned.emit(self, "air_attack")
			swingWeapon(AttackType.AIR)
		else:
			Transitioned.emit(self, "attack")
			swingWeapon(AttackType.GROUND)
		get_hector_attack_sound()

#Plays one of Hector's attack grunts
func get_hector_attack_sound() -> void:
	sound.play_sound_effect_from_library(get_attack_sound())
	var voice_clip = randi_range(0, 4)
	if voice_clip > 0:
		voice.play_sound_effect_from_library("Attack" + str(voice_clip))

#Plays one of Hector's strong attack grunts
func get_hector_heavy_attack_sound() -> void:
	sound.play_sound_effect_from_library(get_attack_sound())
	var voice_clip = randi_range(1, 2)
	if voice_clip > 0:
		voice.play_sound_effect_from_library("heavy_attack_" + str(voice_clip))


#Plays the appropriate animation for the currently equipped weapon
#Crouching attacks are missing
func swingWeapon(anim_type: int):
	if player.sprite.weapon != null:
		if anim_type == AttackType.AIR:
			player.sprite.weapon.play_air(get_attack_speed())
		elif anim_type == AttackType.GROUND:
			player.sprite.weapon.play(get_attack_speed())
		elif anim_type == AttackType.CROUCH:
			player.sprite.weapon.play_crouch(get_attack_speed())

#Allows the player to activate a relic and handles the activation logic along
#with visual effects
func _can_activate_magic():
	const STARTING_GLOW_INTENSITY: float = 3
	const STARTING_GLOW_DURATION: float = 0.4
	const DEACTIVATING_RELIC_GLOW_COLOR: Color = Color(2,2,2,1)
	const DEACTIVATING_RELIC_GLOW_DURATION: float = 0.4
	const NORMAL_COLOR: Color = Color(1,1,1,1)
	const TIME_TO_RETURN_TO_NORMAL_COLOR: float = 0.2
	if not player.isRelicEquipped() or player.activating_magic:
		return
	if self != player.state_machine.current_state:
		return
	if InputBuffer.is_action_press_buffered("circle"):
		if not player.enabled_magic:
			player.aura.modulate = player.relicColor()
			player.activating_magic = true
			player.enabled_magic = true
			play_relic_sound()
			sound.play_sound_effect_from_library("activate_relic")
			var tweener = get_tree().create_tween()
			tweener.tween_property(player.sprite, "self_modulate", player.relicColor()*STARTING_GLOW_INTENSITY, STARTING_GLOW_DURATION)
			await tweener.finished
			tweener = get_tree().create_tween()
			player.aura.visible = player.enabled_magic
			tweener.tween_property(player.sprite, "self_modulate", NORMAL_COLOR, TIME_TO_RETURN_TO_NORMAL_COLOR)
			await tweener.finished
			player.activating_magic = false
			return
		stop_relic_sound()
		player.enabled_magic = false
		player.aura.visible = false
		var tween = get_tree().create_tween()
		tween.tween_property(player.sprite, "self_modulate", DEACTIVATING_RELIC_GLOW_COLOR, DEACTIVATING_RELIC_GLOW_DURATION)
		await tween.finished
		tween = get_tree().create_tween()
		player.aura.visible = false
		tween.tween_property(player.sprite, "self_modulate", NORMAL_COLOR, TIME_TO_RETURN_TO_NORMAL_COLOR)
		await tween.finished

# Plays sounds if the relic has any while it stays active
func play_relic_sound() -> void:
	match player.stats.equipment["relic"]-1:
		Relic.Relics.AGUNIS_LAUREL:
			player.relic_sounds.play_sound_effect_from_library("aguni_laurel")
			
# Stops sounds if the relic had any playing while it was active
func stop_relic_sound() -> void:
	player.relic_sounds.stop()

func stay_crouched():
	player.skip_crouch_anim = true
	Transitioned.emit(self, "crouch")
	
func can_land():
	if player.is_on_floor():
		sound.play_sound_effect_from_library("land")
		if attacking() and not player.can_jump_cancel:
			player.resume_attack = true
			Transitioned.emit(self, "attack")
			return
		TrainingSettings.spawnTrainingHeart(TrainingMode.Training.JUMP_CANCEL)
		run_without_start_anim(true)
		if not player.direction:
			Transitioned.emit(self, "landing")
	
func play_sound(sfx_name: String):
	sound.set_stream(load("res://assets/sounds/" + sfx_name))
	sound.play()
	
func can_die():
	if player.stats.Stats["HP"] <= 0:
		if Global.screen == Global.ScreenType.TRAINING:
			if self is not HectorDamageMercy and self is not HectorHardLanding:
				Transitioned.emit(self, "damage_mercy")
			return
		if player.stats.accessoryEquipped(Accessory.Accessories.RING_OF_LIFE):
			var ring_of_life_effect = player.RING_OF_LIFE_SCENE.instantiate()
			ring_of_life_effect.global_position = player.global_position
			ring_of_life_effect.z_index = player.z_index-1
			ring_of_life_effect.get_child(0).flip_h = player.sprite.flip_h
			MetSys.get_current_room_instance().add_child(ring_of_life_effect)
			player.stats.Stats["HP"] = player.stats.Stats["MHP"]/4
			player.stats.removeEquippedItem(player.stats.searchItemInCompendium(Accessory.Accessories.RING_OF_LIFE, player.stats.accessory_compendium))
		else:
			Transitioned.emit(self, "dying")
		
func attack_anim_suffix() -> String:
	var anims = ["", "_greatsword", "_axe", "_spear", "_fist"]
	if player.stats.equipment["weapon"] == 0:
		return anims[4]
	return anims[player.stats.searchItemInCompendium(player.stats.equipment["weapon"], player.stats.weapon_compendium).type]

func get_attack_speed() -> float:
	
	var speeds = [2, 1, 1, 1, 2]
	if player.stats.equipment["weapon"] == 0:
		return speeds[4]
	return speeds[player.stats.searchItemInCompendium(player.stats.equipment["weapon"], player.stats.weapon_compendium).type]

func get_attack_sound() -> String:
	var sounds = ["sword", "greatsword", "axe", "spear", "punch"]
	if player.stats.equipment["weapon"] == 0:
		return sounds[4]
	return sounds[player.stats.searchItemInCompendium(player.stats.equipment["weapon"], player.stats.weapon_compendium).type]

func is_above_player_within_range(horizontal_range: float, min_vertical_distance: float) -> bool:
	return Global.player.global_position.y > player.global_position.y and abs(Global.player.global_position.y - player.global_position.y) > min_vertical_distance and abs(Global.player.global_position.x - player.global_position.x) < horizontal_range

func is_below_player_within_range(horizontal_range: float, min_vertical_distance: float) -> bool:
	return Global.player.global_position.y < player.global_position.y and abs(Global.player.global_position.y - player.global_position.y) > min_vertical_distance and abs(Global.player.global_position.x - player.global_position.x) < horizontal_range

func in_front_of_player() -> bool:
	return Global.player.global_position.x < player.global_position.x
	
func is_below_player() -> bool:
	return Global.player.global_position.y < player.global_position.y
	
func can_turnaround() -> void:
	player.sprite.flip_h = not in_front_of_player()
	if in_front_of_player():
		player.facing_position = -1
	else:
		player.facing_position = 1
		
# Instead of just flipping the sprite, changes the player scale directly
func can_turnaround_with_scale() -> void:
	var old_facing_position = player.facing_position
	if in_front_of_player():
		player.facing_position = -1
	else:
		player.facing_position = 1
	if old_facing_position != player.facing_position:
		player.scale.x *= (-1)

func enemy_can_die(with_misc_items: bool = true) -> void:
	if player.stats.HP <= 0:
		Transitioned.emit(self, "dying")
		player.stats.determineDrop(with_misc_items)

func turn_around():
	player.scale.x *= (-1)
	for property in player.get_property_list():
		if property["name"] == "facing_position":
			player.facing_position *= -1

func can_use_skill() -> void:
	if Global.player.state_machine.current_state is HectorSitDown or Global.player.state_machine.current_state is HectorWait:
		return
		
	if Input.is_action_just_pressed("innocent_devil_move") and player.stats.Stats["Hearts"] > player.stats.skills[player.current_skill].cost and Global.player.stats.Stats["HP"] > 0:
		Global.player.sound.play_sound_effect_from_library("innocent_command")
		Transitioned.emit(self, "Healing")
