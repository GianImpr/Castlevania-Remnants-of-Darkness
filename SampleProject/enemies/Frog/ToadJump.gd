extends State
class_name ToadJump
const SMALL_JUMP_VELOCITY: Vector2 = Vector2(200, -500)
const MEDIUM_JUMP_VELOCITY: Vector2 = Vector2(300, -350)
const LANDING_COOLDOWN: float = 0.1
var can_idle: bool
var phase: int = 0
const FALLING_FRAME: int = 4
var velocity: Vector2

func enter():
	animation.play("jump")
	phase = 0
	velocity = [SMALL_JUMP_VELOCITY, MEDIUM_JUMP_VELOCITY].pick_random()
	can_idle = false
	get_tree().create_timer(LANDING_COOLDOWN, false).timeout.connect(func(): can_idle = true)
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	
	if player.velocity.y > 0 and phase == 0:
		phase = 1
		player.sprite.frame = FALLING_FRAME
		

	if not animation.is_playing() and player.is_on_floor() and phase == 1:
		player.velocity.x = 0
		animation.play("landing")
		phase = 2
		
	if not animation.is_playing() and phase == 2:
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
	
func applyJump() -> void:
	player.velocity.x = velocity.x*player.facing_position
	player.velocity.y = velocity.y
