extends State
class_name FrozenShadeIdle
var duration: float
const MIN_DURATION: float = 0.5
const MAX_DURATION: float = 1.2
const ACTIONS: Array[String] = ["icicle", "freeze"]
var can_act: bool
const SPEED: float = 150
var velocity_tween: Tween
const CHANGE_VELOCITY_INTERVAL: float = 1.5
const FREEZE_THRESHOLD: float = 200

func enter():
	animation.play("idle")
	applyVelocity()
	can_act = false
	duration = randf_range(MIN_DURATION, MAX_DURATION)
	get_tree().create_timer(duration, false).timeout.connect(func(): can_act = true)
	
func exit():
	velocity_tween.kill()
	player.velocity = Vector2.ZERO

func Update(delta: float):
	enemy_can_die()
	if sign(player.facing_position) != sign(Global.player.global_position.x - player.global_position.x):
		Transitioned.emit(self, "turning")
		
	if can_act and player.activated_AI:
		Transitioned.emit(self, decideAction())


func Physics_Update(delta: float):
	pass

func decideAction() -> String:
	if absf(Global.player.global_position.x - player.global_position.x) < FREEZE_THRESHOLD:
		return ACTIONS.pick_random()
	return "icicle"

func applyVelocity() -> void:
	velocity_tween = get_tree().create_tween()
	velocity_tween.set_trans(Tween.TRANS_SINE)
	velocity_tween.set_ease(Tween.EASE_IN_OUT)
	velocity_tween.tween_property(player, "velocity", Vector2(SPEED, SPEED) * Vector2(randf_range(-1,1), randf_range(-1,1)), CHANGE_VELOCITY_INTERVAL)
	if not velocity_tween.finished.is_connected(applyVelocity):
		velocity_tween.finished.connect(applyVelocity)
