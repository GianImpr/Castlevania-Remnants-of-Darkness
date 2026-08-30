extends State
class_name HectorDamageAir
@export var blood: CPUParticles2D
var can_perfect_guard: bool = false
const RECOIL_SPEED: Vector2 = Vector2(250, -350)
const HEIGHT_DECELERATION: float = 0.95
const CAN_DOUBLE_JUMP_AFTER: float = 0.2
static var applyMercyInvincibility: Callable
var allow_double_jump: bool

func enter():
	animation.play("hurt_air", -1, 1)
	blood.emitting = true
	allow_double_jump = false
	player.velocity.x = RECOIL_SPEED.x * player.facing_position * (-1)
	player.velocity.y = RECOIL_SPEED.y
	get_tree().create_timer(CAN_DOUBLE_JUMP_AFTER, false).timeout.connect(func(): allow_double_jump = true)
	
func exit():
	if Global.game != null and Global.game.difficulty == Game.Difficulty.SIMPLIFIED:
		applyMercyInvincibility.call()
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_die()
	if allow_double_jump:
		can_double_jump()
	
	if player.is_on_floor():
		Transitioned.emit(self, "hard_landing")
