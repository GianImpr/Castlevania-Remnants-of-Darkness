extends State
class_name EctoplasmIdle
@export var IDLE_SPEED: Vector2
@export_range(0, 5, 0.1, "suffix:s") var NAVIGATION_CYCLE_DURATION: float
const WHIFF_FLYING_THRESHOLD: float = 200

func enter():
	player.velocity = Vector2.ZERO
	player.initializeNavigation(IDLE_SPEED, NAVIGATION_CYCLE_DURATION)
	player.register_knockback = true
	
func exit():
	player.navigationDone()
	player.register_knockback = false

func Update(_delta: float):
	enemy_can_die()
	enemy_check_is_hurt("hit")
	
	
	
func Physics_Update(_delta: float):
	pass
