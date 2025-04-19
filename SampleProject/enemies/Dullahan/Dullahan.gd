extends Enemy
class_name Dullahan
var spawn_spikes: bool = false
var spike_position: float
var phase_two: bool = false
var facing_position: int = -1
var max_HP: int

@export_category("Projectiles")
@export var spike_start_position: Vector2
@export var spike_min_x_position: float
@export var spike_max_x_position: float
@export var spike_scene: PackedScene
@export var fang_scene: PackedScene
@export var projectile_scene: PackedScene
@export var spike_respawn_timer: Timer
@export_category("Hitboxes")
@export var thrust_hitbox: Area2D
@export var shockwave_hitbox: Area2D
@export var laser_hitbox: Area2D
@export var trigger_boss: Area2D
@export var hurtbox: CollisionShape2D
@export var state_machine: Node
@export_category("Other")
@export var head_sprite: Sprite2D


const Actions = {
	IDLE = "idle",
	WALKING = "walking",
	THRUST = "thrust",
	SHOCKWAVE = "shockwave",
	NEEDLES = "needles",
	TELEPORT = "teleport",
	LASER = "laser",
	HEAD = "throw_head"
}

func _ready() -> void:
	super()
	max_HP = stats.HP
	

func _physics_process(delta: float) -> void:
	if not is_on_floor() and not hurtbox.disabled:
		velocity += get_gravity()*2 * delta
	remove_glow_if_glowing()
	move_and_slide()
	
func decide_action(from_index: int = 0, to_index: int = Actions.size()-1) -> String:
	var action = Actions.values()[randi_range(from_index, to_index)]
	if stats.HP <= max_HP/2 and not phase_two:
		phase_two = true
		return "enter_rage"
	if isCorneringPlayer():
		return Actions.TELEPORT
	if action == Actions.THRUST and abs(Global.player.global_position.x - global_position.x) > 300:
		action = Actions.WALKING
	return action


func _on_hitbox_body_entered(body: Node2D) -> void:
	if state_machine.current_state is not DullahanTeleport:
		hit_target(1, body, hitbox_iframe, 0, false, Global.Attribute.HIT, 1)


func _on_thrust_body_entered(body: Node2D) -> void:
	hit_target(1.5, body, thrust_hitbox, 5)


func _on_shockwave_body_entered(body: Node2D) -> void:
	hit_target(3, body, shockwave_hitbox, 30, true, Global.Attribute.ICE)

func spawnSpikes() -> void:
	var spike = spike_scene.instantiate()
	get_parent().get_parent().add_child(spike)
	spike.stats.thrower_ATK = stats.ATK
	spike.global_position = global_position + Vector2(spike_start_position.x * facing_position, spike_start_position.y)
	spike.global_position.x = spike.global_position.x + spike_position * facing_position
	spike.scale.x = facing_position
	spike_position += 30
	if spike.global_position.x < spike_min_x_position or spike.global_position.x > spike_max_x_position:
		spike_respawn_timer.stop()
		spawn_spikes = false
	
func initSpikes() -> void:
	spike_position = 0
	DullahanSpikes.on_cooldown = false
	spawn_spikes = true
	spike_respawn_timer.start()
	
func spawnFang() -> void:
	var fang = fang_scene.instantiate()
	get_parent().get_parent().add_child(fang)
	fang.stats.thrower_ATK = stats.ATK
	fang.on_cooldown = false
	fang.global_position = Vector2(Global.player.global_position.x, 418)
	
func spawnProjectiles() -> void:
	for angle in range(0, 360, 20):
		var projectile = projectile_scene.instantiate()
		get_parent().get_parent().add_child(projectile)
		projectile.stats.thrower_ATK = stats.ATK
		projectile.global_position = head_sprite.global_position
		projectile.sprite.rotation_degrees = angle
		projectile.adjustFlyingDirection()
		
	

func shakeCamera() -> void:
	Global.camera.apply_shake()

func _on_start_cooldown_timeout() -> void:
	trigger_boss.monitoring = true
	
func isCorneringPlayer() -> bool:
	return abs(Global.player.global_position.x - global_position.x) < 140 and (global_position.x < 220 or global_position.x > 740)


func _on_laser_2_body_entered(body: Node2D) -> void:
	hit_target(2.8, body, laser_hitbox, 25, true, Global.Attribute.FIRE, 1)
	
func setBossBar() -> void:
	if boss and state_machine.current_state is DullahanAppearing and Global.boss_bar.enemy != self:
		Global.boss_bar.enemy = self

func _on_spikes_timeout() -> void:
	spawnSpikes()
