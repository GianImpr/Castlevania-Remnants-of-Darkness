extends State
class_name GhostBounce
var tween

func enter():
	player.velocity.x *= -1
	player.velocity.y *= -1
	tween = get_tree().create_tween()
	tween.tween_property(player, "velocity", Vector2(0, 0), 1)
	tween.connect("finished", endBounce)
	
func exit():
	tween.kill()
	
func Update(delta: float):
	enemy_can_die()
	
func endBounce():
	Transitioned.emit(self, "move")

func Physics_Update(delta: float):
	pass
