extends State
class_name WargTurning
const WARG_IDLE_FRAME: int = 0

func enter():
	player.velocity.x = 0
	animation.play("turn")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing():
		player.sprite.frame = WARG_IDLE_FRAME
		player.facing_position *= -1
		player.scale.x *= -1
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
