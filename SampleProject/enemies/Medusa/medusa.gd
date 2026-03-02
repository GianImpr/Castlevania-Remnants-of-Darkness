extends Enemy
class_name Medusa

var facing_position: int
@export var is_moving: bool = true
@export var contact_damage_multiplier: float = 1
@export_category("Sword")
@export var sword_hitbox: Area2D
@export var sword_damage_multiplier: float = 1.5
@export var sword_chip_damage: int = 5
@export_category("Laser")
@export var laser_hitbox: Area2D
@export var laser_damage_multiplier: float = 0.1
@export var laser_chip_damage: int = 0
@export_category("Dash")
@export var dash_hitbox: Area2D
@export var dash_damage_multiplier: float = 2
@export var dash_chip_damage: int = 30
@export_category("Other")
@export var state_machine: Node
var max_HP: int

const ACTIONS = {
	BEAM = "beam",
	SUMMON = "summon",
	STONECIRCLE = "stone_circle",
	DASH = "dash"
}

func _ready() -> void:
	super()
	facing_position = 1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.area_entered.connect(_on_area_2d_area_entered)
	sword_hitbox.area_entered.connect(_on_sword_area_entered)
	laser_hitbox.area_entered.connect(_on_laser_area_entered)
	dash_hitbox.area_entered.connect(_on_dash_area_entered)
	max_HP = stats.HP

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(contact_damage_multiplier, body, hitbox_iframe)

func _on_sword_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(sword_damage_multiplier, body, sword_hitbox, sword_chip_damage, false, Global.Attribute.SLASH)

func _on_laser_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(laser_damage_multiplier, body, laser_hitbox, laser_chip_damage, false, Global.Attribute.STONE)

func _on_dash_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(dash_damage_multiplier, body, dash_hitbox, dash_chip_damage, true, Global.Attribute.SLASH, 1, true)


func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)

func setBossBar() -> void:
	if boss and Global.boss_bar.enemy != self:
		Global.boss_bar.enemy = self

func decideAction() -> void:
	const PLAYER_NEARBY_DISTANCE: float = 100
	
	if abs(Global.player.global_position.x - global_position.x) < PLAYER_NEARBY_DISTANCE and abs(Global.player.global_position.y - global_position.y) < PLAYER_NEARBY_DISTANCE and not Global.player.is_on_floor():
		state_machine.current_state.Transitioned.emit(state_machine.current_state, "sword")
		return
	var action: String = ACTIONS.values().pick_random()
	if stats.HP > max_HP/1.3 and action == "stone_circle":
		action = ["sword", "beam", "dash"].pick_random()
	state_machine.current_state.Transitioned.emit(state_machine.current_state, action)
