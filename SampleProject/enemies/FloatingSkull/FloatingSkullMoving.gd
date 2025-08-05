extends State
class_name FloatingSkullMoving
@export var MIN_SPEED: float
@export var MAX_SPEED: float
@export_range(0, 3, 0.1, "suffix:s") var MIN_DURATION: float
@export_range(0, 3, 0.1, "suffix:s") var MAX_DURATION: float
var tween: Tween

func enter():
	player.velocity.x = randf_range(MIN_SPEED, MAX_SPEED) * player.facing_position
	player.velocity.y = (Global.player.global_position.y - player.global_position.y) * 1.5
	player.velocity.y = max(MIN_SPEED, min(abs(player.velocity.y), MAX_SPEED)) * sign(player.velocity.y)
	animation.play("biting")
	tween = get_tree().create_tween()
	tween.tween_property(player, "velocity", Vector2(0, 0), randf_range(MIN_DURATION, MAX_DURATION))
	tween.finished.connect(func(): Transitioned.emit(self, "idle"))
	
func exit():
	if tween.is_running():
		tween.kill()
	
func Update(delta: float):
	enemy_can_die()
