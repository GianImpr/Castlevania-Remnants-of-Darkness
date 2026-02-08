extends State
class_name FrozenShadeTurning
const IDLE_FRAME: int = 0

func enter():
	player.velocity.x = 0
	animation.play("turning")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing():
		player.sprite.frame = IDLE_FRAME
		player.facing_position *= -1
		player.scale.x *= -1
		Transitioned.emit(self, "idle")


func Physics_Update(delta: float):
	pass
