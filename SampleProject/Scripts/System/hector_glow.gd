extends Sprite2D

var enable_glow: bool = false
var start_fade: bool = false
var influence_glow: float = 0
var extra_influence_duration: float = 0
@export var glow_speed: float
@export var glow_timer: Timer
var applied_color: Color
var applied_influence: float
var trail_direction: int = 1
var weapon: WeaponSprite
@export var initial_weapon_sprite: PackedScene
@export var hector_hands: Sprite2D

func _process(delta: float) -> void:
	# Apply glow according to the buff/debuff
	if not enable_glow and not get_parent().hit_effect_applied:
		if Global.player.stats.status[Global.player.stats.Status.CURSE] > 0:
			editShaderParams(0.2, 6, true, Color.YELLOW, true)
		elif Global.player.stats.status[Global.player.stats.Status.POISON] > 0:
			editShaderParams(0.2, 6, true, Color.MAGENTA, true)
		elif Global.player.stats.status[Global.player.stats.Status.ENFEEBLE] > 0:
			editShaderParams(0.2, 6, true, Color.RED, true)
		elif Global.player.stats.status[Global.player.stats.Status.REFRESHING_AIR] > 0:
			editShaderParams(0.2, 2, true, Color(0.5, 0, 1))
		else:
			editShaderParams(0, 0, false)
		
	# Relic activation glow
	if enable_glow and not start_fade and glow_timer.is_stopped() and not get_parent().hit_effect_applied:
		editShaderParams(influence_glow, 2, true)
		influence_glow = min(influence_glow + glow_speed * delta, 0.07)
		if influence_glow >= 0.07:
			glow_timer.start()
	elif material.get_shader_parameter("enabled") and influence_glow == 0 and not get_parent().hit_effect_applied:
		#editShaderParams(0, 0, false)
		start_fade = false
		enable_glow = false
		
	# Level up glow
	if start_fade and not get_parent().hit_effect_applied:
		influence_glow = max(influence_glow - glow_speed * delta, 0)
		editShaderParams(influence_glow, 2, true)
	elif get_parent().hit_effect_applied:
		if extra_influence_duration > 0:
			extra_influence_duration -= glow_speed * delta
		else:
			influence_glow = max(influence_glow - glow_speed * delta, 0)
			material.set_shader_parameter("influence", influence_glow)
		if influence_glow == 0:
			material.set_shader_parameter("enabled", false)
			get_parent().hit_effect_applied = false
	
	if weapon != null:
		flipWeapon()
		
func _physics_process(delta: float) -> void:
	if get_parent().aura.frame != frame and not get_parent().state_machine.current_state is HectorIdle or get_parent().aura.frame != 0 and frame == 0:
		get_parent().aura.frame = frame
		
	if get_parent().aura.flip_h != flip_h:
		get_parent().aura.flip_h = flip_h

	
func editShaderParams(influence: float, speed: float, enabled: bool, color: Color = Color(1,1,1), mix_colors: bool = false) -> void:
	if color == applied_color and influence == applied_influence and material.get_shader_parameter("enabled"):
		return
	applied_color = color
	applied_influence = influence
	material.set_shader_parameter("mix_colors", mix_colors)
	material.set_shader_parameter("color", color)
	material.set_shader_parameter("influence", influence)
	material.set_shader_parameter("speed", speed)
	material.set_shader_parameter("enabled", enabled)
	
func setPetrify(active: bool) -> void:
	material.set_shader_parameter("petrified", active)


func _on_glow_timeout() -> void:
	start_fade = true

# Swaps between two weapons
func changeWeapon(new_weapon_scene: PackedScene) -> void:
	removeWeapon()
	if new_weapon_scene:
		var new_weapon_node = new_weapon_scene.instantiate()
		var new_weapon: WeaponSprite
		if new_weapon_node is WeaponSprite:
			new_weapon = new_weapon_node
		else:
			new_weapon = new_weapon_node.get_child(0)
		if new_weapon.hitbox != null:
			new_weapon.hitbox.player = Global.player
			new_weapon.hitbox.sound = Global.player.sound
			new_weapon.hitbox.state_machine = Global.player.state_machine
		weapon = new_weapon
		if weapon.has_parent_node:
			add_child(new_weapon_node)
		else:
			add_child(new_weapon)

# Removes the currently loaded weapon
func removeWeapon() -> void:
	if weapon != null and not weapon.has_parent_node:
		weapon.queue_free()
	elif weapon != null and weapon.has_parent_node:
		weapon.get_parent().queue_free()

# Flips the weapon animation accordingly to the player's facing position
func flipWeapon() -> void:
	if Global.player.facing_position != weapon.facing_position:
		weapon.flip()
