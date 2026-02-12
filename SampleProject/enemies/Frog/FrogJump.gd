extends State
class_name FrogJump
const SMALL_JUMP_VELOCITY: Vector2 = Vector2(100, -300)
const MEDIUM_JUMP_VELOCITY: Vector2 = Vector2(200, -450)
const HIGH_JUMP_VELOCITY: Vector2 = Vector2(400, -650)
const LANDING_COOLDOWN: float = 0.1
var can_idle: bool

func enter():
	animation.play("jump")
	var velocity: Vector2 = [SMALL_JUMP_VELOCITY, MEDIUM_JUMP_VELOCITY, HIGH_JUMP_VELOCITY].pick_random()
	player.velocity.x = velocity.x*player.facing_position
	player.velocity.y = velocity.y
	can_idle = false
	get_tree().create_timer(LANDING_COOLDOWN, false).timeout.connect(func(): can_idle = true)
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	
	if not animation.is_playing() or (player.is_on_floor() and can_idle):
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
