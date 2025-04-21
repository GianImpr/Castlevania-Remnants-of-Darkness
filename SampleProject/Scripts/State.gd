extends Node
class_name State
signal Transitioned
var player: CharacterBody2D
var animation: AnimationPlayer
var sound
var voice
const Actions = {
	JUMP = "jump",
	BACKDASH = "backdash",
	CROUCH = "crouch"
}

func enter():
	pass
	
func exit():
	pass
	
func Update(_delta: float):
	pass
	
func Physics_Update(_delta: float):
	pass
	
func can_perform(anim_name: String, just_pressed: bool):
	if just_pressed:
		if InputBuffer.is_action_press_buffered(anim_name):
			Transitioned.emit(self, anim_name)
	else:
		if Input.is_action_pressed(anim_name):
			Transitioned.emit(self, anim_name)

func run_without_start_anim(skip_run_start_animation: bool):
	if player.direction:
		player.skip_run_start = skip_run_start_animation
		Transitioned.emit(self, "run")

func can_fall(coyote_effect: bool):
	if not player.is_on_floor():
		if coyote_effect:
			player.coyote_timer.start()
		Transitioned.emit(self, "falling")
		
func can_drop_ledge():
	if player.is_on_floor() and InputBuffer.is_action_press_buffered("jump") and Input.is_action_pressed("crouch"):
		player.position.y += 1
		
func can_guard():
	if player.stats.findItem(1, player.stats.skill_inventory):
		can_perform("guard", false)
		player.stats.Stats["Guard"] = max(player.stats.Stats["Guard"], 1)
	else:
		player.stats.Stats["Guard"] = 0

func can_turn():
	if player.direction == 1:
		player.sprite.flip_h = false
	elif player.direction == -1:
		player.sprite.flip_h = true
		
func can_move_with_momentum(keep_momentum: bool):
	if player.direction:
		player.velocity.x = player.direction * player.SPEED
	else:
		if keep_momentum:
			player.velocity.x *= 0.91
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
			
func remove_momentum():
	player.velocity.x = 0
	
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
	
func check_is_hurt():
	if player.state_machine.current_state is HectorGuardPerfectAir:
		return
	if player.is_hurt and player.stats.Stats["HP"] > 0:
		player.current_hits_taken_before_iframes += 1
		player.mercy_invincibility_hit_threshold_reset.start()
		if player.is_on_floor() and not self is HectorCrouch and player.current_hits_taken_before_iframes != player.IFRAMES_HIT_THRESHOLD:
			Transitioned.emit(self, "damage")
		elif not player.is_on_floor():
			Transitioned.emit(self, "damage_air")
		elif player.current_hits_taken_before_iframes != player.IFRAMES_HIT_THRESHOLD:
			Transitioned.emit(self, "damage")
		else:
			Transitioned.emit(self, "damage_mercy")
		var voice_clip = randi_range(0, 2)
		if voice_clip > 0 and player.is_on_floor() and player.current_hits_taken_before_iframes != player.IFRAMES_HIT_THRESHOLD:
			voice.play_sound_effect_from_library("Hit" + str(voice_clip))
		elif voice_clip > 0 and (not player.is_on_floor() or player.current_hits_taken_before_iframes == player.IFRAMES_HIT_THRESHOLD):
			voice.play_sound_effect_from_library("HeavyHit")
	elif player.stats.Stats["HP"] == 0:
		sound.play_sound_effect_from_library("damage")
		
func attacking() -> bool:
	return (self is HectorAttack or self is HectorAirAttack or self is HectorCrouchAttack)

func can_attack():
	if self != player.state_machine.current_state:
		return
	if InputBuffer.is_action_press_buffered("attack"):
		if (self is HectorCrouch or self is HectorRise) and player.can_crouch_attack:
			Transitioned.emit(self, "crouch_attack")
		elif not player.is_on_floor():
			Transitioned.emit(self, "air_attack")
			swingWeapon(true)
		else:
			Transitioned.emit(self, "attack")
			swingWeapon(false)
		sound.play_sound_effect_from_library(get_attack_sound())
		var voice_clip = randi_range(0, 4)
		if voice_clip > 0:
			voice.play_sound_effect_from_library("Attack" + str(voice_clip))

func swingWeapon(air_anim: bool):
	if player.sprite.weapon != null:
		if air_anim:
			player.sprite.weapon.play_air()
		else:
			player.sprite.weapon.play()

func _can_activate_magic():
	if not player.isRelicEquipped() or player.activating_magic:
		return
	if self != player.state_machine.current_state:
		return
	if InputBuffer.is_action_press_buffered("circle"):
		if not player.enabled_magic:
			player.activating_magic = true
			player.enabled_magic = true
			sound.play_sound_effect_from_library("activate_relic")
			var tweener = get_tree().create_tween()
			tweener.tween_property(player.sprite, "self_modulate", player.relicColor()*3, 0.4)
			await tweener.finished
			tweener = get_tree().create_tween()
			player.aura.visible = player.enabled_magic
			tweener.tween_property(player.sprite, "self_modulate", Color(1, 1, 1, 1), 0.2)
			await tweener.finished
			player.activating_magic = false
			return
		player.enabled_magic = not player.enabled_magic
		player.aura.visible = player.enabled_magic
		var tween = get_tree().create_tween()
		tween.tween_property(player.sprite, "self_modulate", Color(2, 2, 2, 1), 0.4)
		await tween.finished
		tween = get_tree().create_tween()
		player.aura.visible = player.enabled_magic
		tween.tween_property(player.sprite, "self_modulate", Color(1, 1, 1, 1), 0.2)
		await tween.finished


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
		run_without_start_anim(true)
		if not player.direction:
			Transitioned.emit(self, "landing")
	
func play_sound(sfx_name: String):
	sound.set_stream(load("res://assets/sounds/" + sfx_name))
	sound.play()
	
func can_die():
	if player.stats.Stats["HP"] <= 0:
		Transitioned.emit(self, "dying")
		
func attack_anim_suffix() -> String:
	var anims = ["", "_fist", "_axe"]
	if player.stats.equipment["weapon"] == 0:
		return anims[1]
	return anims[player.stats.searchItemInCompendium(player.stats.equipment["weapon"], player.stats.weapon_compendium).type]

func get_attack_speed() -> float:
	var speeds = [2, 2, 1]
	if player.stats.equipment["weapon"] == 0:
		return speeds[1]
	return speeds[player.stats.searchItemInCompendium(player.stats.equipment["weapon"], player.stats.weapon_compendium).type]

func get_attack_sound() -> String:
	var sounds = ["sword", "punch", "axe"]
	if player.stats.equipment["weapon"] == 0:
		return sounds[1]
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
	if Input.is_action_just_pressed("innocent_devil_move") and player.stats.Stats["Hearts"] > player.stats.skills[player.current_skill].cost and Global.player.stats.Stats["HP"] > 0:
		Global.player.sound.play_sound_effect_from_library("innocent_command")
		Transitioned.emit(self, "Healing")
