extends State
class_name RockKnightWalking
const SPEED: float = 75
const MIN_DURATION: float = 0.5
const MAX_DURATION: float = 1.5
var can_act: bool
var directions: Array[int] = [-1, 1]

func enter():
	can_act = false
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(func(): can_act = true)
	player.velocity.x = SPEED*directions.pick_random()
	animation.play("walking")
	
func exit():
	player.velocity.x = 0

func Update(delta: float):
	enemy_can_die()
	if player.stay_idle:
		player.velocity.x = 0
	
	if sign(player.facing_position) != sign(Global.player.global_position.x - player.global_position.x):
		Transitioned.emit(self, "turning")
		
	if can_act:
		Transitioned.emit(self, "throw")


func Physics_Update(delta: float):
	pass
