extends InnocentDevil
class_name Crow

var funny_wall_destination: Vector2

var current_evolution: Evolutions = Evolutions.CROW
var is_hurt: bool = false
@export var evolutions: Array[Dictionary]
@export var hurtbox_area: Area2D
@export var damage_popup: DamagePopup
@export var detection: Area2D
@export var dash_frequency_timer: Timer

var detected_enemies: Array[Enemy]
var targeted_enemy: Enemy
var can_dash: bool = false
var invincible: bool = false
var prepare_for_flight: bool = false
var can_glide: bool = true

const DEFAULT_DASH_TIMER: float = 4

enum Evolutions {
	CROW
}

const EvolutionData = {
	NAME = "name",
	BODY = "sprite_body",
	IMAGE = "image"
}

func _ready() -> void:
	Global.HUD.switchIdModeColor(Global.HUD.ID_OFFENSIVE_MODE_COLOR)
	current_skill = Ability.GLIDE
	facing_position = 1
	detection.body_entered.connect(onEnemyDetected)
	detection.body_exited.connect(onEnemyLost)
	dash_frequency_timer.timeout.connect(determineDash)
	dash_frequency_timer.start()
	
func _process(delta: float) -> void:
	super(delta)
	hurtbox_area.set_collision_layer_value(14, (not is_hurt) and is_alive and (not invincible))
	
	if Global.player.is_on_floor():
		can_glide = true
	
	if targeted_enemy and targeted_enemy.stats.HP <= 0:
		targetWeakerEnemy()

func onEnemyDetected(body: Node2D) -> void:
	if not body is Enemy:
		return
	detected_enemies.append(body)
	targetWeakerEnemy()
	
func onEnemyLost(body: Node2D) -> void:
	if not body is Enemy:
		return
	detected_enemies.erase(body)
	targetWeakerEnemy()
	
func targetWeakerEnemy() -> void:
	targeted_enemy = null
	for enemy: Enemy in detected_enemies:
		if not targeted_enemy:
			targeted_enemy = enemy
			continue
			
		if isEnemyWeakerThan(enemy, targeted_enemy):
			targeted_enemy = enemy

func determineDash() -> void:
	can_dash = true
	dash_frequency_timer.wait_time = DEFAULT_DASH_TIMER - float(stats.Stats["LV"])/5
	dash_frequency_timer.start()

func isEnemyWeakerThan(target: Enemy, to: Enemy) -> bool:
	var expected_damage_ratio_target: float = float(stats.Stats["ATK"] - target.stats.DEF/2) / target.stats.HP
	var expected_damage_ratio_to: float = float(stats.Stats["ATK"] - to.stats.DEF/2) / to.stats.HP
	return (expected_damage_ratio_target < expected_damage_ratio_to and target.stats.LV < to.stats.LV and target.stats.HP > 0) or to.stats.HP <= 0

func updateCurSkillTransition() -> void:
	match current_skill:
		Ability.GLIDE:
			skill_transitions_to_state = "glide"
			prepare_for_flight = true

func isGuarding() -> bool:
	const GUARDING_COEFFICIENT: float = 256
	const MINIMUM_GUARDING_ODDS: float = 16
	var guarding_odds: float = MINIMUM_GUARDING_ODDS+stats.Stats["LV"]
	return randi_range(0, 1) <= guarding_odds/GUARDING_COEFFICIENT or mode == Mode.DEFENSIVE

func onModeChanged(new_mode: Mode) -> void:
	can_dash = false
	dash_frequency_timer.start()
