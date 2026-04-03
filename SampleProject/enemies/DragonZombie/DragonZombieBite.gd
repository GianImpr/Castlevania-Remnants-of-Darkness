extends State
class_name DragonZombieBite
var dash_tween: Tween
const MAX_SPEED: float = -700
const TWEEN_DURATION: float = 0.3

func enter():
	animation.play("bite")
	
func exit():
	if dash_tween and dash_tween.is_running():
		dash_tween.kill()
	player.velocity.x = 0

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass

func applyDashSpeed() -> void:
	dash_tween = get_tree().create_tween()
	dash_tween.tween_property(player, "velocity:x", 0, TWEEN_DURATION).from(MAX_SPEED)
