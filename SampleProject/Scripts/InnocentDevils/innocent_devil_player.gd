extends CharacterBody2D
class_name InnocentDevil
var facing_position: int = -1
signal evolved

@export var id: int
@export var id_name: String
@export var stats: InnocentDevilStats
@export var state_machine: Node
@export var vanishing_particles: CPUParticles2D
@export var spawn_particles: CPUParticles2D
@export var evo_particles: GPUParticles2D
@export var sparkles: CPUParticles2D
@export var sprite: Sprite2D
@export var sound: PolyphonicAudio
@export var voice: PolyphonicAudio
@export var animation: AnimationPlayer
@export var evolution_animation: AnimationPlayer
@export var collision: CollisionShape2D
var is_alive: bool = true
var lock_current_skill: bool = false
var current_skill: Ability = Ability.HEAL
var skill_transitions_to_state: String
var can_change_mode: bool = true
var attack_blocked: bool = false
var allow_evo_crystals: bool = true

const SPAWN_TWEEN_DURATION: float = 1
const SPAWN_POSITION_OFFSET: Vector2 = Vector2(100, -100)

var mode: Mode = Mode.OFFENSIVE:
	set(value):
		if mode == value:
			return
			
		mode = value
		match mode:
			Mode.OFFENSIVE:
				Global.HUD.switchIdModeColor(Global.HUD.ID_OFFENSIVE_MODE_COLOR)
				onModeChanged(Mode.OFFENSIVE)
			Mode.DEFENSIVE:
				Global.HUD.switchIdModeColor(Global.HUD.ID_DEFENSIVE_MODE_COLOR)
				onModeChanged(Mode.DEFENSIVE)
		state_machine.polyphonic_audio_player.play_sound_effect_from_library("change_mode")

enum Mode {
	OFFENSIVE,
	DEFENSIVE
}

const MAX_LEVEL: int = 99

enum Ability {
	HEAL,
	REFRESHING_AIR,
	TIME_HEAL,
	GLIDE,
	RESIST_FIRE_ICE,
	POISON_POWDER
}

func _ready() -> void:
	lock_current_skill = false
	updateSpriteToCurrentEvolution()
	
func _process(delta: float) -> void:
	if not is_alive:
		return
		
	if stats.Stats["EXP"] >= stats.expNeededToLvUp() and stats.Stats["LV"] < MAX_LEVEL:
		stats.levelUp()
	
	if lock_current_skill:
		return
	
	if Input.is_action_just_pressed("next_skill"):
		current_skill = posmod((current_skill+1),stats.skills.size())
		while not stats.skills[current_skill].unlocked:
			current_skill = posmod((current_skill+1),stats.skills.size())
	elif Input.is_action_just_pressed("previous_skill"):
		current_skill = posmod((current_skill-1),stats.skills.size())
		while not stats.skills[current_skill].unlocked:
			current_skill = posmod((current_skill-1),stats.skills.size())
	elif Input.is_action_just_pressed("rstick_up") and can_change_mode:
		mode = Mode.OFFENSIVE
	elif Input.is_action_just_pressed("rstick_down") and can_change_mode:
		mode = Mode.DEFENSIVE
		

		
func _physics_process(delta: float) -> void:
	if not is_on_floor() and not motion_mode == MotionMode.MOTION_MODE_FLOATING:
		velocity += get_gravity() * delta


	move_and_slide()

func createInnocentDevilEntry() -> InnocentDevilEntry:
	var entry: InnocentDevilEntry = InnocentDevilEntry.new()
	entry.getDataFromIDStats(self)
	return entry
	
func updateStatsInEntry() -> void:
	for entry in Global.player.innocent_devil_pocket:
		if entry.id == id:
			entry.updateStats(self)
			return

func updateCurSkillTransition() -> void:
	pass

func isGuarding() -> bool:
	return false
	
func transitionToState(new_state_name: String) -> void:
	state_machine.current_state.Transitioned.emit(state_machine.current_state, new_state_name)

func summon() -> void:
	transitionToState("spawn")
	modulate = Color.TRANSPARENT
	var hurtbox: Area2D
	if "hurtbox_area" in self:
		hurtbox = self.hurtbox_area
		hurtbox.set_collision_layer_value(1, false)
		hurtbox.set_collision_layer_value(13, false)
	if not is_alive:
		return
	var spawn_tween: Tween
	animation.play("idle")
	global_position = Global.player.global_position + Vector2(SPAWN_POSITION_OFFSET.x*Global.player.facing_position, SPAWN_POSITION_OFFSET.y)
	voice.play_sound_effect_from_library("revive")
	sparkles.emitting = true
	get_tree().create_timer(0.1, false).timeout.connect(func(): spawn_particles.emitting = true)
	spawn_tween = get_tree().create_tween()
	spawn_tween.tween_property(self, "modulate", Color.WHITE, SPAWN_TWEEN_DURATION)
	await spawn_tween.finished
	if hurtbox:
		hurtbox.set_collision_layer_value(13, true)
	transitionToState("idle")

func dismiss() -> void:
	const DISMISS_TWEEN_DURATION: float = 2
	var dismiss_tween: Tween = get_tree().create_tween()
	dismiss_tween.tween_property(self, "modulate", Color.TRANSPARENT, DISMISS_TWEEN_DURATION)
	transitionToState("dismiss")

func onModeChanged(new_mode: Mode) -> void:
	pass

func shine(evo_crystal_type: EvoCrystal.Type) -> void:
	const EVO_CRYSTAL_COLORS: Array[Color] = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.WHITE]
	evo_particles.modulate = EVO_CRYSTAL_COLORS[evo_crystal_type]
	evo_particles.emitting = true

func getHurtboxCenter() -> Vector2:
	return collision.global_position + Vector2(collision.shape.size.x/2, collision.shape.size.y/2)

func updateSpriteToCurrentEvolution() -> void:
	pass

func evolve(new_evolution: int) -> void:
	const EVOLUTION_UPDATE_MESSAGE_DURATION: float = 3
	const DARK_TWEEN_DURATION: float = 0.4
	const NORMAL_LIGHT_DURATION: float = 0.1
	var darkening_tween: Tween
	stats.Stats["AP"] = 0
	process_mode = Node.PROCESS_MODE_ALWAYS
	top_level = true
	get_tree().paused = true
	darkening_tween = get_tree().create_tween()
	darkening_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	darkening_tween.tween_property(get_tree().current_scene, "modulate", Color.DIM_GRAY, DARK_TWEEN_DURATION)
	Global.screen = Global.ScreenType.EVENT
	transitionToState("freeze")
	evolution_animation.play("evolve")
	await evolved
	self.current_evolution = new_evolution
	updateSpriteToCurrentEvolution()
	Global.player.heal_innocent(9999)
	await evolution_animation.animation_finished
	darkening_tween = get_tree().create_tween()
	darkening_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	darkening_tween.tween_property(get_tree().current_scene, "modulate", Color.WHITE, NORMAL_LIGHT_DURATION)
	get_tree().paused = false
	top_level = false
	Global.screen = Global.ScreenType.NONE
	Global.tutorial_box.popup(id_name + " evolved into [color=yellow]" + self.evolutions[self.current_evolution][self.EvolutionData.NAME] + "[/color].", EVOLUTION_UPDATE_MESSAGE_DURATION)
	process_mode = Node.PROCESS_MODE_INHERIT
	canEvolve()
	
func checkShouldEvolve() -> void:
	const CANNOT_EVOLVE: int = -1
	var evolve_to: int = canEvolve()
	if evolve_to != CANNOT_EVOLVE:
		evolve(evolve_to)

## Returns the ID of the form the devil can evolve to.
## Returns -1 else.
func canEvolve() -> int:
	const MAX_TIER: int = 1 ##3 once all evolutions are done
	var current_evo: int = self.current_evolution
	var evo_crystals: int = 0
	var possible_evolutions: Array[int] = [current_evo-current_evo%2+1, current_evo-current_evo%2+2]
	
	if current_evo >= MAX_TIER:
		return -1
	
	for evolution in possible_evolutions:
		var evo_crystals_needed: int = self.evolutions[evolution][self.EvolutionData.EVO_CRYSTALS_REQUIRED]

		for i in range(0, EvoCrystal.Type.size()):
			if self.evolutions[evolution][self.EvolutionData.EVO_CRYSTALS_ACCEPTED][i]:
				evo_crystals += stats.evo_crystals[i]

		if evo_crystals >= evo_crystals_needed:
			for i in range(0, EvoCrystal.Type.size()):
				if self.evolutions[evolution][self.EvolutionData.EVO_CRYSTALS_ACCEPTED][i]:
					stats.evo_crystals[i] = 0
			return evolution
	return -1
