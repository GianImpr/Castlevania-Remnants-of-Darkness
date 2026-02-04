extends State
class_name EctoplasmFlying
@export var FLYING_SPEED: Vector2
@export_range(0, 5, 0.1, "suffix:s") var NAVIGATION_CYCLE_DURATION: float
@export_range(0, 5, 0.1, "suffix:s") var FLOATING_DURATION: float


func enter():
	get_tree().create_timer(FLOATING_DURATION).timeout.connect(Transitioned.emit.bind(self, "idle"))
	var random_multiplier: float = randf_range(0.3, 1)
	player.initializeNavigation(FLYING_SPEED*(1/random_multiplier), NAVIGATION_CYCLE_DURATION*random_multiplier)
	
func exit():
	player.navigationDone()

func Update(_delta: float):
	enemy_can_die()
	
func Physics_Update(_delta: float):
	pass
