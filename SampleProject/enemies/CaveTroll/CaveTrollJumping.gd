extends State
class_name CaveTrollJumping
const SPEED: Vector2 = Vector2(300, -400)
const JUMPING_FRAME: int = 1
const PEAK_FRAME: int = 2
const DESCENDING_FRAME: int = 3
const PEAK_VELOCITY: float = 30

func enter():
	animation.stop()
	player.sprite.frame = JUMPING_FRAME
	player.velocity.x = SPEED.x*player.facing_position
	player.velocity.y = SPEED.y
	
func exit():
	player.velocity = Vector2.ZERO

func Update(delta: float):
	enemy_can_die()
	if abs(player.velocity.y) < PEAK_VELOCITY:
		player.sprite.frame = PEAK_FRAME
	elif player.velocity.y >= PEAK_VELOCITY:
		player.sprite.frame = DESCENDING_FRAME
		
	if player.is_on_floor() and player.sprite.frame != JUMPING_FRAME:
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
