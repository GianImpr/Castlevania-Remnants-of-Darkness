extends State
class_name HectorSitDown
var can_perfect_guard: bool = false


func enter():
	animation.play("sitting_down", -1, 1.3)
	player.velocity.x = 0
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	pass
