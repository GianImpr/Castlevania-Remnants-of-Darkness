extends State
class_name CrowDash
const SPEED: float = 500
const MIN_DURATION: float = 0.8
const MAX_DURATION: float = 1.2

@export var dash_vfx_scene: PackedScene
@export var dash_respawn_timer: Timer
@export var dash_hitbox: CollisionShape2D
const MAX_ATTACK_ANGLE: float = PI/6

func enter():
	if randi_range(0,1) == 0:
		voice.play_sound_effect_from_library("attack_" + str(randi_range(1,2)))
	player.can_dash = false
	dash_hitbox.set_deferred("disabled", false)
	animation.play("dash")
	player.hurtbox_area.set_deferred("monitorable", false)
	dash_respawn_timer.start()
	if not dash_respawn_timer.timeout.is_connected(spawnDashVfx):
		dash_respawn_timer.timeout.connect(spawnDashVfx)
	var target_hurtbox: CollisionShape2D = player.targeted_enemy.getHurtbox()
	var target_angle: float = player.global_position.angle_to_point(target_hurtbox.global_position)
	
	#Clamps angle to max angle
	if abs(target_angle) > PI/2:
		target_angle = max(PI-MAX_ATTACK_ANGLE, abs(target_angle))*sign(target_angle)
	else:
		target_angle = min(MAX_ATTACK_ANGLE, abs(target_angle))*sign(target_angle)
		
	#target_angle = sign(target_angle)*min(abs(target_angle), MAX_ATTACK_ANGLE)
	player.velocity = Vector2(cos(target_angle), sin(target_angle)) * SPEED
	#duration could last based on how distant it is from the enemy?
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(func(): if player.state_machine.current_state == self: Transitioned.emit(self, "fly"))
	
func exit():
	player.hurtbox_area.set_deferred("monitorable", true)
	dash_respawn_timer.stop()
	
func Update(delta: float):
	can_use_skill()
	innocent_check_is_hurt("hurt")
	innocent_can_die()
		
func Physics_Update(delta: float):
	if sign(player.velocity.x)*player.facing_position < 0:
		turn_around()
		
func spawnDashVfx() -> void:
	var dash_vfx = dash_vfx_scene.instantiate()
	dash_vfx.global_position = player.global_position
	if player.facing_position == -1:
		dash_vfx.scale.x *= -1
	dash_vfx.z_index = player.z_index+1
	MetSys.get_current_room_instance().add_child(dash_vfx)
