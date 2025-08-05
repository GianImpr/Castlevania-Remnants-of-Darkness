extends State
class_name KamikazeRavenMoving
@export var SPEED: float
@export var TRACKING_SPEED: float
@export_range(0, 3, 0.1, "suffix:s") var TIME_FOR_MAX_SPEED: float
@export var explode_timer: Timer
var tween: Tween

func enter():
	explode_timer.start()
	explode_timer.timeout.connect(func(): player.explode())
	tween = get_tree().create_tween()
	tween.bind_node(player)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(player, "velocity", Vector2(SPEED * player.facing_position, (Global.player.global_position.y - player.global_position.y)*5) , TIME_FOR_MAX_SPEED)
	
func exit():
	explode_timer.stop()
	if tween.is_running():
		tween.kill()

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass
