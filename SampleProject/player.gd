extends CharacterBody2D
class_name HectorPlayer

@export_category("Innocent Devils")
@export var innocent_devil_scene: PackedScene
@export var innocent_devil_pocket: Array[InnocentDevilEntry]
@export var pocket_size: int = 0
@export var summoned_innocent_devil_id: int = -1
@export_category("Player")
@export var sprite: Sprite2D
@export var aura: Sprite2D
@export var state_machine: Node
@export var damage_popup: DamagePopup
@export var stats: HectorStats
@export var hurtbox: CollisionShape2D
@export var sound: PolyphonicAudio
@export var boost_message: PackedScene
@export var guard_recovery: Timer
@export var coyote_timer: Timer
@export var perfect_guard_timer: Timer
@export var mercy_invincibility_duration: Timer
@export var mercy_invincibility_hit_threshold_reset: Timer
@export var focus_gain_duration: Timer
@export var reset_guard_presses_timer: Timer
@export_category("Buff nodes")
@export var confidence_ring_timer: Timer
@export_category("Charge nodes")
@export var charge_sprite: Sprite2D
@export var charge_anim: AnimationPlayer
@export var charge_particles: CPUParticles2D
@export_category("Temporary nodes")
@export var heal_effect: GPUParticles2D
@export var heal_mp_effect: GPUParticles2D
@export var tap_up: TapUp
@export var effects: Node
@export var special_attack_animation: AnimationPlayer
@export var throw_axe: PackedScene
@export var raycast: RayCast2D
@export var aguni_flames: PackedScene
@export var relic_sounds: PolyphonicAudio

const AGUNI_LAUREL_COST_PER_SECOND: int = 15
var aguni_mp_consumption: float = 0
const AGUNI_COOLDOWN: float = 0.03
var aguni_on_cooldown: bool = false

const STONE_OF_ALCHEMY_HEAL: int = 5
const BLOOD_CLOAK_HEAL: int = 2
const SPEED = 260.0
const IFRAMES_HIT_THRESHOLD: int = 3
const FOCUS_GAIN_RATIO: int = 10
const GUARD_RECOVERY_TIME: int = 3
const MAX_WEAPON_RANK = 1
const LONG_MERCY_INVINCIBILITY_DURATION: float = 1.7
const SHORT_MERCY_INVINCIBILITY_DURATION: float = 0.8
const MAX_GUARD_PRESS_PER_HALF_SECOND: int = 3
const RING_OF_LIFE_SCENE: PackedScene = preload("res://SampleProject/extra_scenes/effects/ring_of_life_effect.tscn")

var current_hits_taken_before_iframes: int = 0
var reset_position: Vector2
var facing_position: int
var skip_crouch_anim: bool
var innocent_devil
var direction: int = 0
var skip_run_start: bool = false
var can_jump_cancel: bool = true
var can_crouch_attack: bool = true
var resume_attack: bool = false
var is_hurt: bool = false
var knockback: bool = false
var guarding: bool = false
var unlocked_magic: bool = false
var enabled_magic: bool = false
var activating_magic: bool = false
var hit_effect_applied: bool = false
const PERFECT_GUARD_WINDOW_SIMPLIFIED: float = 0.192
const PERFECT_GUARD_WINDOW_DEFAULT: float = 0.096

const CHARGE_ONE_COST_RATIO: int = 10
var cur_charge: Charge = Charge.NONE
var times_guard_pressed: int = 0

const Animations = {
	ATTACK_AIR = "air_attack",
	ATTACK = "attack",
	ATTACK_CROUCH = "crouch_attack",
	CROUCH = "crouch",
	DYING = "dying",
	GUARD_BREAK = "guard_break",
	GUARD_RAISE = "raise_guard",
	GUARD_WALK = "guard_walk",
	GUARDING = "guarding",
	HARD_LANDING = "hard_landing",
	HURT = "hurt",
	HURT_AIR = "hurt_air",
	IDLE = "idle",
	JUMP = "jump",
	LANDING = "landing",
	LEVEL_UP = "level_up",
	PERFECT_GUARDING = "perfect_guarding",
	PERFECT_GUARDING_AIR = "perfect_guarding_air",
	RUN = "run",
	RUN_END = "run_end",
	RUN_START = "run_start",
	SITTING = "sitting_down"
}

enum Charge {
	ONE,
	TWO,
	THREE,
	NONE
}

func _ready() -> void:
	Global.player = self
	reset_guard_presses_timer.timeout.connect(func(): times_guard_pressed = 0)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if (event as InputEventKey).keycode == KEY_0:
			print(InputHelper.serialize_inputs_for_actions())
	
func _process(delta: float) -> void:
	#If harmed, become invulnerable for a while
	set_collision_layer_value(2, not is_hurt and mercy_invincibility_duration.is_stopped() and not state_machine.current_state is HectorWait)
	
	guarding = isGuarding()
	
	if Input.is_action_just_pressed("guard") and can_perfect_guard() and not is_hurt:
		times_guard_pressed += 1
		if times_guard_pressed <= MAX_GUARD_PRESS_PER_HALF_SECOND:
			if Global.game.difficulty == Global.game.Difficulty.SIMPLIFIED:
				perfect_guard_timer.start(PERFECT_GUARD_WINDOW_SIMPLIFIED)
			else:
				perfect_guard_timer.start(PERFECT_GUARD_WINDOW_DEFAULT)
		else:
			reset_guard_presses_timer.start()
	elif not Input.is_action_pressed("guard") and not perfect_guard_timer.is_stopped():
		perfect_guard_timer.stop()
		
	if innocent_devil != null:
		summoned_innocent_devil_id = innocent_devil.id
	
	# Can't recover guard health while guard broken
	if state_machine.current_state is HectorGuardBreak or stats.Stats["Guard"] == 3:
		guard_recovery.stop()
	elif guard_recovery.is_stopped():
		var actual_recovery_time: float = GUARD_RECOVERY_TIME
		if stats.canApplySkill(Skill.Skills.STEADY_FIGHTER):
			guard_recovery.start(actual_recovery_time*0.9)
			
		if Global.game != null and Global.game.difficulty == Game.Difficulty.SIMPLIFIED:
			actual_recovery_time /= 2
		guard_recovery.start(actual_recovery_time)
		
	if stats.Stats["EXP"] >= expNeededToLvUp() and stats.Stats["LV"] < 99:
		levelUp()
		
	if expNeededToRankUpWeapon() <= 0:
		weaponRankUp()
		
	if Global.screen == Global.ScreenType.TRAINING and TrainingSettings.cur_challenge == TrainingMode.Training.TECHNIQUES:
		stats.Stats["FP"] = stats.Stats["MFP"]-1
		
	if not focus_gain_duration.is_stopped() and cur_charge == Charge.NONE:
		if stats.Stats["FP"] < stats.Stats["MFP"] and stats.Stats["FP"]+FOCUS_GAIN_RATIO*delta >= stats.Stats["MFP"]:
			fullFocusEffect()
		stats.Stats["FP"] = min(stats.Stats["MFP"], stats.Stats["FP"]+FOCUS_GAIN_RATIO*delta)
		
	if cur_charge == Charge.ONE:
		stats.Stats["FP"] = max(0, stats.Stats["FP"]-CHARGE_ONE_COST_RATIO*delta)
		if stats.Stats["FP"] == 0:
			disableCharge()

	if enabled_magic and stats.itemEquipped(Relic.Relics.AGUNIS_LAUREL, "relic") and stats.Stats["MP"] > 0 and not aguni_on_cooldown and velocity.x != 0 and is_on_floor():
		aguni_on_cooldown = true
		get_tree().create_timer(AGUNI_COOLDOWN).timeout.connect(func(): aguni_on_cooldown = false)
		aguni_mp_consumption += (delta+AGUNI_COOLDOWN)*AGUNI_LAUREL_COST_PER_SECOND
		if aguni_mp_consumption >= 1:
			aguni_mp_consumption = 0
			stats.Stats["MP"] -= 1
		var flame = aguni_flames.instantiate()
		flame.global_position = global_position + Vector2(20*facing_position,66) - MetSys.get_current_room_instance().global_position
		MetSys.get_current_room_instance().add_child(flame)

	removeSwordTrail()

func _physics_process(delta: float) -> void:	
	# Add the gravity.
	if not is_on_floor() and not motion_mode == MotionMode.MOTION_MODE_FLOATING:
		velocity += get_gravity()*2 * delta

	direction = round(Input.get_axis("move_left", "move_right"))
	
	# Update where Hector is facing
	if sprite.flip_h:
		facing_position = -1
	else:
		facing_position = 1
		
	# Debug features
	if Input.is_action_just_pressed("reset"): # and Global.is_debug_mode:
		get_tree().reload_current_scene()
	
	
	# Respawn Innocent Devil if not yet present in the scene
	if innocent_devil_scene and innocent_devil == null:
		innocent_devil = innocent_devil_scene.instantiate()
		get_parent().add_child(innocent_devil)
		innocent_devil.position = Vector2(position.x - 100 *facing_position,position.y)
		
	move_and_slide()

# Unused, comes from the Metroidvania System plugin test.
# Might come in handy later on while reloading saves.
func kill():
	position = reset_position
	Game.get_singleton().load_room(MetSys.get_current_room_name())

# (Unused as well) Position for kill system. Assigned when entering new room (see Game.gd).
func on_enter():
	reset_position = position
	
func weaponRankUp():
	const POPUP_DURATION: float = 3
	sound.play_sound_effect_from_library("rank_up")
	sprite.enable_glow = true # Rainbow effect on Hector
	var weapon_type: int = 4
	if stats.equipment["weapon"] != 0:
		weapon_type = stats.searchItemInCompendium(stats.equipment["weapon"], stats.weapon_compendium).type
	stats.weapon_proficiency[weapon_type]["lv"] += 1
	var skills_learned: Array[String]
	for i in range(0, stats.skill_compendium.size()):
		var skill: Skill = stats.skill_compendium[i]
		
		if skill.type != Skill.SkillType.LEARNABLE:
			continue

		if skill.weapon_type == weapon_type and skill.weapon_rank == stats.weapon_proficiency[weapon_type]["lv"]:
			skills_learned.append(skill.skill_name)
			stats.addItem(i+1, stats.skill_inventory)
			
	Global.tutorial_box.activate = true
	Global.tutorial_box.time = 3
	Global.tutorial_box.text = tr("SKILLS_LEARNED_MESSAGE") % [tr(skills_learned[0]), tr(skills_learned[1])]

func levelUp():
	var popup = boost_message.instantiate()
	sprite.enable_glow = true # Rainbow effect on Hector
	add_child(popup)
	stats.Stats["LV"] += 1
	for stat in ["MHP", "MMP", "STR", "CON", "INT", "LCK", "SYN", "RES"]:
		if (stat == "MMP" and unlockedMagic()) or stat != "MMP":
			stats.Bases[stat] = stats.Initial[stat] + int(stats.Growths[stat]/100.0*(stats.Stats["LV"]))
		if stat not in ["MHP", "MMP"]:
			stats.Stats[stat] = stats.Bases[stat] + stats.Boosts[stat]
	stats.Bases["ATK"] = stats.Stats["STR"]/2
	stats.Bases["DEF"] = stats.Stats["CON"]/2
	stats.Stats["ATK"] = stats.Bases["ATK"] + stats.Boosts["ATK"]
	stats.Stats["DEF"] = stats.Bases["DEF"] + stats.Boosts["DEF"]
	stats.Stats["MHP"] = stats.Bases["MHP"] + stats.Boosts["HP"]
	if unlockedMagic():
		stats.Stats["MMP"] = stats.Bases["MMP"] + stats.Boosts["MP"]
	else:
		stats.Stats["MMP"] = 0
		
	if Global.game.difficulty == Game.Difficulty.SIMPLIFIED:
		stats.Stats["HP"] = stats.Stats["MHP"]
		stats.Stats["MP"] = stats.Stats["MMP"]
		stats.Stats["FP"] = stats.Stats["MFP"]
	
func expNeededToLvUp() -> int:
	return (13*pow(stats.Stats["LV"], 3)+39*pow(stats.Stats["LV"], 2)+104*stats.Stats["LV"]+100)/6
	
func expNeededToRankUpWeapon() -> int:
	var weapon_type: int = 4
	var allowed_weapon_types: Array[Weapon.Type] = [Weapon.Type.SWORD, Weapon.Type.AXE, Weapon.Type.GREATSWORD, Weapon.Type.SPEAR, Weapon.Type.FIST]
	var extra_level_for: Array[Weapon.Type] = [Weapon.Type.FIST]
	if stats.equipment["weapon"] != 0:
		weapon_type = stats.searchItemInCompendium(stats.equipment["weapon"], stats.weapon_compendium).type
	var next_weapon_lv = stats.weapon_proficiency[weapon_type]["lv"]+1
	var cur_weapon_exp = stats.weapon_proficiency[weapon_type]["exp"]
	var remaining_exp: int = 100*next_weapon_lv*1.5*log(next_weapon_lv*1.5+2.7)-cur_weapon_exp
	if (next_weapon_lv > MAX_WEAPON_RANK and weapon_type not in extra_level_for) or (next_weapon_lv > MAX_WEAPON_RANK+1 and weapon_type in extra_level_for) or weapon_type not in allowed_weapon_types:
		return 1
	return remaining_exp
	
# Is the MP bar enabled?
func unlockedMagic() -> bool:
	return unlocked_magic

# Enables the MP bar
func unlockMagic():
	stats.Bases["MMP"] = stats.Initial["MMP"] + int(stats.Growths["MMP"]/100.0*(stats.Stats["LV"]))
	stats.Stats["MMP"] = stats.Bases["MMP"] + stats.Boosts["MP"]
	stats.Stats["MP"] = stats.Stats["MMP"]
	unlocked_magic = true
	
func isGuarding() -> bool:
	return state_machine.current_state is HectorGuard or state_machine.current_state is HectorGuardWalk or isPerfectGuarding() or state_machine.current_state is HectorGuardBlocking

func isPerfectGuarding() -> bool:
	return state_machine.current_state.can_perfect_guard and willPerfectGuard()

func willPerfectGuard() -> bool:
	return not perfect_guard_timer.is_stopped()
	
func isAttacking() -> bool:
	return state_machine.current_state.attack_state

# Guard health recovery tick
func _on_guard_recovery_timeout() -> void:
	stats.Stats["Guard"] = min(stats.Stats["Guard"]+1, 3)
	
	
func isRelicEquipped() -> bool:
	return stats.equipment["relic"] > 0
	
# Used to determine the color of Hector's aura and glow when using a relic
func relicColor() -> Color:
	return stats.relic_compendium[stats.equipment["relic"]-1]["glow"]
	
func can_perfect_guard() -> bool:
	return stats.findItem(Skill.Skills.PLATINUM_ARM, stats.skill_inventory) > 0

func addExp(amount: int) -> void:
	stats.Stats["EXP"] += amount
	if innocent_devil != null:
		innocent_devil.stats.Stats["EXP"] += amount
		
func addWeaponExp() -> void:
	var amount_gained = 1
	var weapon_type: int = 4
	if stats.equipment["weapon"] != 0:
		weapon_type = stats.searchItemInCompendium(stats.equipment["weapon"], stats.weapon_compendium).type
	
	if weapon_type == Weapon.Type.AXE:
		amount_gained = 2
		
	stats.weapon_proficiency[weapon_type]["exp"] += amount_gained
	
func heal(amount: int, with_particles: bool = true) -> void:
	if state_machine.current_state is HectorDying:
		return
		
	sprite.influence_glow = 0.2
	sprite.extra_influence_duration = 0
	hit_effect_applied = true
	sprite.editShaderParams(0.2, 4, true, Color(0, 0.766, 0))
	stats.Stats["HP"] = min(stats.Stats["HP"]+amount, stats.Stats["MHP"])
	damage_popup.popup(amount, 2)

	if with_particles:
		heal_effect.emitting = true
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "self_modulate", Color(0.3,1.4,0.7), 0.3)
		await tween.finished
		tween = get_tree().create_tween()
		tween.tween_property(sprite, "self_modulate", Color(1,1,1), 1)
	
func healMP(amount: int, popup_offset: Vector2 = Vector2.ZERO) -> void:
	stats.Stats["MP"] = min(stats.Stats["MP"]+amount, stats.Stats["MMP"])
	heal_mp_effect.emitting = true
	damage_popup.popup(amount, 3, popup_offset)

	
func heal_innocent(amount: int) -> void:
	if innocent_devil != null:
		innocent_devil.stats.Stats["Hearts"] = min(innocent_devil.stats.Stats["Hearts"]+amount, innocent_devil.stats.Stats["MHearts"])

## Player stays in idle animation
func freeze() -> void:
	transitionToState("wait")
	
## Player can move again
func unfreeze() -> void:
	transitionToState("idle")
	
func removeSwordTrail() -> void:
	if not (state_machine.current_state is HectorAttack or state_machine.current_state is HectorAirAttack or state_machine.current_state is HectorCrouchAttack):
		sprite.weapon_trail.frame = 3
		
func applyHitEffect(type: Global.Attribute) -> void:
	sprite.influence_glow = 0.2
	sprite.extra_influence_duration = 0
	hit_effect_applied = true
	if type != Global.Attribute.NONE and type != Global.Attribute.SLASH and type != Global.Attribute.HIT and type != Global.Attribute.STONE:
		effects.get_child(int(type)-3).emitting = true
	match type:
		Global.Attribute.FIRE:
			sound.play_sound_effect_from_library("hit_fire")
			sprite.editShaderParams(0.2, 4, true, Color(0.766, 0, 0))
			sprite.self_modulate = Color(1, 0.674, 0.426)
		Global.Attribute.ICE:
			sound.play_sound_effect_from_library("hit_ice")
			sprite.editShaderParams(0.2, 4, true, Color(0, 0, 1))
			sprite.self_modulate = Color(0, 0.639, 0.89)
		_:
			sound.play_sound_effect_from_library("damage")
			sprite.editShaderParams(0.2, 4, true, Color(0.766, 0, 0))
			sprite.self_modulate = Color(1, 0, 0)

	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "self_modulate", Color(1,1,1), 0.1)


func _on_iframe_hit_counter_reset_timeout() -> void:
	current_hits_taken_before_iframes = 0

func playSpecialAttackEffect() -> void:
	special_attack_animation.play("trigger")

func fullFocusEffect() -> void:
	sound.play_sound_effect_from_library("focus_full")
	var tween: Tween = get_tree().create_tween()
	const GLOW_DURATION: float = 0.4
	tween.tween_property(sprite, "self_modulate", Color(0.1, 2, 4), GLOW_DURATION).from(Color(0.1, 1.5, 2.5))
	tween.tween_property(sprite, "self_modulate", Color(1, 1, 1), GLOW_DURATION/2)

func throwAxe() -> void:
	var axe = throw_axe.instantiate()
	axe.global_position = position + Vector2(98*facing_position, -5)
	MetSys.get_current_room_instance().add_child(axe)

func petrify() -> void:
	stats.current_status = stats.Ailment.STONE
	
#Creates one afterimage instance of Hector
func instantiateScene(scene: PackedScene, get_player_frame: bool, offset: Vector2):
	var instance: Sprite2D = scene.instantiate()
	instance.scale = scale
	instance.global_position = global_position + offset - MetSys.get_current_room_instance().position
	instance.flip_h = sprite.flip_h
	instance.z_index = z_index-1
	if get_player_frame:
		instance.frame = sprite.frame
		instance.texture = sprite.texture
		instance.hframes = sprite.hframes
		instance.vframes = sprite.vframes
	MetSys.get_current_room_instance().add_child(instance)

func activateBloodCloak() -> void:
	heal_innocent(BLOOD_CLOAK_HEAL)

func activateStoneOfAlchemy() -> void:
	healMP(STONE_OF_ALCHEMY_HEAL, Vector2(0,28))

func activateCharge(level: Charge) -> void:
	const anims = ["charge_lv1", "charge_lv2", "charge_lv3"]
	sound.play_sound_effect_from_library("charge")
	charge_particles.one_shot = false
	charge_anim.play(anims[level])
	cur_charge = level
	
func disableCharge() -> void:
	charge_particles.one_shot = true
	cur_charge = Charge.NONE

func transitionToState(state: String) -> void:
	state_machine.current_state.Transitioned.emit(state_machine.current_state, state)
