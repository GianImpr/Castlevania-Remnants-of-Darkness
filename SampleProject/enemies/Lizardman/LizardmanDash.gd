extends State
class_name LizardmanDash
const STOP_AT_DISTANCE: float = 130
var phase: int = -1
@export var sword_hitbox: CollisionShape2D
@export var trail: Sprite2D
@export var red_spark_scene: PackedScene
@export var max_duration_timer: Timer
const TRAIL_DEFAULT_FRAME: int = 170
const DECELERATION_TWEEN_DURATION: float = 0.6
const INITIAL_SWING_TIME: float = 0.35
const DASH_SPEED: float = 300

func enter():
	if not max_duration_timer.timeout.is_connected(dashAttack):
		max_duration_timer.timeout.connect(dashAttack)
	animation.stop()
	phase = -1
	can_turnaround_with_scale()
	var red_spark = red_spark_scene.instantiate()
	player.add_child(red_spark)
	await get_tree().create_timer(1, false).timeout
	if player.stats.HP <= 0:
		return
	animation.play("dashing")
	max_duration_timer.start()
	can_turnaround_with_scale()
	player.dash_attacking = true
	player.velocity.x = DASH_SPEED*player.facing_position
	phase = 0
	
func exit():
	sword_hitbox.set_deferred("disabled", true)
	trail.frame = TRAIL_DEFAULT_FRAME
	player.velocity.x = 0

func Update(delta: float):
	enemy_can_die()
	
	if phase == 0 and horizontal_distance_from_player() < STOP_AT_DISTANCE:
		phase = 1
		max_duration_timer.stop()
		
	if phase == 1:
		var deceleration_tween: Tween = get_tree().create_tween()
		deceleration_tween.tween_property(player, "velocity:x", 0, DECELERATION_TWEEN_DURATION)
		animation.play("swing")
		animation.seek(INITIAL_SWING_TIME)
		phase = 2
		deceleration_tween.finished.connect(func(): phase = 3 if phase == 2 else phase)
		
	if not animation.is_playing() and phase == 3:
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass

func dashAttack() -> void:
	phase = 1
