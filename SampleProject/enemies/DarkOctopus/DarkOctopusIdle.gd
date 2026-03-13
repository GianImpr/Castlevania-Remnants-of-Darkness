extends State
class_name DarkOctopusIdle
const SPEED: float = 60
var direction: int = 1
var ACTIVE_FROM_DISTANCE: float = 300
const CHANGE_DIRECTION_AFTER_SECONDS: float = 1
const MIN_DURATION: float = 0.2
const MAX_DURATION: float = 2.5
var distance_from_player: float
var can_act: bool 

func enter():
	animation.play("idle")
	if Global.player.global_position < player.global_position:
		direction = -1
	else:
		direction = 1
	can_act = false
	player.velocity.x = direction * SPEED
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(func(): can_act = true)
	get_tree().create_timer(CHANGE_DIRECTION_AFTER_SECONDS).timeout.connect(changeDirection)
	
func exit():
	pass

func Update(delta: float):
	distance_from_player = abs(Global.player.global_position.x - player.global_position.x)
	if can_act and distance_from_player <= ACTIVE_FROM_DISTANCE:
		Transitioned.emit(self, "ink")
	enemy_can_die()

func Physics_Update(delta: float):
	pass
	
func changeDirection() -> void:
	direction = [1, -1].pick_random()
	player.velocity.x = direction * SPEED
	get_tree().create_timer(CHANGE_DIRECTION_AFTER_SECONDS).timeout.connect(changeDirection)
