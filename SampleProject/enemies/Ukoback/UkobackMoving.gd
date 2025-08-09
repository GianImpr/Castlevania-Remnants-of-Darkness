extends State
class_name UkobackMoving
@export var speed: Vector2
@export var spawn_fire_timer: Timer
@export_range(0, 2, 0.1, "suffix:s") var spawn_fire_base_time: float
@export_range(0, 2, 0.1, "suffix:s") var spawn_fire_random_offset: float
var should_count_hit: bool

func _ready() -> void:
	spawn_fire_timer.timeout.connect(spawnFire)

func enter():
	player.moving_up = bool(randi_range(0, 1))
	player.velocity = Vector2(speed.x * player.facing_position, speed.y * -1 * (int(player.moving_up)*2-1))
	animation.play("moving")
	spawn_fire_timer.wait_time = spawn_fire_base_time + randf_range(-spawn_fire_random_offset, spawn_fire_random_offset)
	spawn_fire_timer.start()
	
func exit():
	spawn_fire_timer.stop()

func Update(delta: float):
	player = player as Ukoback
	if player.raycast_down.is_colliding() and not player.moving_up:
		player.moving_up = true
		player.velocity.y = speed.y * -1
	elif player.raycast_up.is_colliding() and player.moving_up:
		player.moving_up = false
		player.velocity.y = speed.y
	
	if player.ray_cast_2d_right.is_colliding():
		turn_around()
		player.velocity.x *= -1
		
	enemy_can_die()
	
	if player.blood_particles.emitting and should_count_hit:
		player.hits_taken += 1
		should_count_hit = false
		if player.hits_taken >= player.HIT_KNOCKBACK_THRESHOLD:
			Transitioned.emit(self, "damage")
			player.hits_taken = 0
		
	if not player.blood_particles.emitting:
		should_count_hit = true

func Physics_Update(delta: float):
	pass
	
func spawnFire() -> void:
	const FLAME_POSITION_OFFSET: Vector2 = Vector2(18, 0)
	var flame = player.flame_projectile_scene.instantiate()
	MetSys.get_current_room_instance().add_child(flame)
	flame.stats.thrower_ATK = player.stats.ATK
	flame.global_position = player.global_position + FLAME_POSITION_OFFSET*player.facing_position
	spawn_fire_timer.wait_time = spawn_fire_base_time + randf_range(-spawn_fire_random_offset, spawn_fire_random_offset)
	spawn_fire_timer.start()
	sound.play_sound_effect_from_library("fireball")
