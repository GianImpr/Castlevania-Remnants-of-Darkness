extends State
class_name MermanSwimming
@export var swimming_timer: Timer
@export var sprite: Sprite2D
const EMERGE_SPEED: Vector2 = Vector2(0, -680)
const EMERGE_DURATION: float = 0.25
const SWIM_SPEED: float = 40
const TWEEN_DURATION: float = 1
const SWIMMING_MIN_DURATION: float = 2
const SWIMMING_MAX_DURATION: float = 4
const INITIAL_SWIM_VELOCITY: Vector2 = Vector2(0, -400)
const INITIAL_SWIM_VELOCITY_DURATION: float = 0.5

const SPRITE_OFFSET_WHILE_SPINNING: Vector2 = Vector2(7,8)
const EMERGING_FRAME: int = 4
const SPINNING_FRAME: int = 5

const ROTATING_CYCLE_DURATION: float = 0.5

var swimming_tween: Tween
var rotating_tween: Tween

var phase: int

func _ready() -> void:
	swimming_timer.timeout.connect(emerge)

func enter():
	if player.spawn_idle:
		return

	phase = 0
	player.set_collision_layer_value(3, false)
	player.set_collision_mask_value(1, false)
	var swimming_duration: float = randf_range(SWIMMING_MIN_DURATION, SWIMMING_MAX_DURATION)
	player.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	swimming_timer.wait_time = swimming_duration
	swimming_timer.start()
	animation.play("swimming")
	player.velocity = INITIAL_SWIM_VELOCITY
	swimming_tween = get_tree().create_tween()
	swimming_tween.tween_property(player, "velocity", Vector2.ZERO, INITIAL_SWIM_VELOCITY_DURATION)
	swimming_tween.finished.connect(swim)
	
	
func exit():
	pass

func Update(delta: float):
	can_turnaround_with_scale()
	enemy_can_die()
	
	if player.spawn_idle:
		sprite.offset = Vector2.ZERO
		Transitioned.emit(self, "idle")
		return
		
	if phase == 1 and player.velocity.y > 0 and not sprite.frame == SPINNING_FRAME:
		sprite.frame = SPINNING_FRAME
		startSpinning()
	

func Physics_Update(delta: float):
	if player.is_on_floor() and not player.spawn_idle:
		sprite.offset = Vector2.ZERO
		if rotating_tween:
			rotating_tween.kill()
		sprite.rotation_degrees = 0
		animation.play("recoil")
		await animation.animation_finished
		Transitioned.emit(self, "idle")


func emerge():
	swimming_tween.kill()
	player.set_collision_layer_value(3, true)
	var emerge_tween: Tween = get_tree().create_tween()
	emerge_tween.set_trans(Tween.TRANS_SPRING)
	emerge_tween.set_ease(Tween.EASE_OUT)
	emerge_tween.tween_property(player, "velocity", EMERGE_SPEED, EMERGE_DURATION)
	animation.stop()
	sprite.frame = EMERGING_FRAME
	phase = 1
	await emerge_tween.finished
	player.set_collision_mask_value(1, true)
	player.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED

func swim() -> void:
	swimming_tween = get_tree().create_tween()
	swimming_tween.bind_node(player)
	swimming_tween.set_loops()
	swimming_tween.tween_property(player, "velocity", Vector2(randf_range(-SWIM_SPEED, SWIM_SPEED), -SWIM_SPEED), TWEEN_DURATION)
	swimming_tween.tween_property(player, "velocity", Vector2(randf_range(-SWIM_SPEED, SWIM_SPEED), SWIM_SPEED), TWEEN_DURATION)

func startSpinning() -> void:
	sprite.offset = SPRITE_OFFSET_WHILE_SPINNING
	rotating_tween = get_tree().create_tween()
	rotating_tween.bind_node(player)
	rotating_tween.tween_property(sprite, "rotation", -PI*2, ROTATING_CYCLE_DURATION).from(0)
	rotating_tween.set_loops()
