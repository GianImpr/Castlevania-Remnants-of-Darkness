extends State
class_name RockKnightIdle
var can_act: bool
const IDLE_DURATION: float = 0.3

func enter():
	can_act = false
	get_tree().create_timer(IDLE_DURATION, false).timeout.connect(func(): can_act = true)
	
	
func exit():
	pass

func Update(delta: float):
	if can_act and player.activated_AI:
		Transitioned.emit(self, "walking")
		
	enemy_can_die()
	if sign(player.facing_position) != sign(Global.player.global_position.x - player.global_position.x):
		Transitioned.emit(self, "turning")


func Physics_Update(delta: float):
	pass
