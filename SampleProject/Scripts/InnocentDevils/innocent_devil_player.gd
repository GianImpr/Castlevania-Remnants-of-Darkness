extends CharacterBody2D
class_name InnocentDevil
var facing_position: int = -1

@export var id: int = 1
@export var id_name: String
@export var stats: InnocentDevilStats
@export var state_machine: Node
@export var vanishing_particles: CPUParticles2D
@export var spawn_particles: CPUParticles2D
@export var sparkles: CPUParticles2D
@export var sprite: Sprite2D
@export var sound: PolyphonicAudio
@export var voice: PolyphonicAudio
@export var animation: AnimationPlayer
var is_alive: bool = true
var current_skill: Ability = Ability.HEAL
var skill_transitions_to_state: String
var can_change_mode: bool = true
var attack_blocked: bool = false
var allow_evo_crystals: bool = true

const SPAWN_TWEEN_DURATION: float = 1
const SPAWN_POSITION_OFFSET: Vector2 = Vector2(0, -150)

var mode: Mode = Mode.OFFENSIVE:
	set(value):
		if mode == value:
			return
			
		mode = value
		match mode:
			Mode.OFFENSIVE:
				Global.HUD.switchIdModeColor(Global.HUD.ID_OFFENSIVE_MODE_COLOR)
			Mode.DEFENSIVE:
				Global.HUD.switchIdModeColor(Global.HUD.ID_DEFENSIVE_MODE_COLOR)
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
	GLIDE
}
	
func _process(delta: float) -> void:
	if not is_alive:
		return
		
	if stats.Stats["EXP"] >= stats.expNeededToLvUp() and stats.Stats["LV"] < MAX_LEVEL:
		stats.levelUp()
		
	if Input.is_action_just_pressed("next_skill"):
		current_skill = (current_skill+1)%stats.skills.size()
		while not stats.skills[current_skill].unlocked:
			current_skill = (current_skill+1)%stats.skills.size()
	elif Input.is_action_just_pressed("previous_skill"):
		current_skill = (current_skill-1)%stats.skills.size()
		while not stats.skills[current_skill].unlocked:
			current_skill = (current_skill-1)%stats.skills.size()
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
	global_position = Global.player.global_position + SPAWN_POSITION_OFFSET
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
